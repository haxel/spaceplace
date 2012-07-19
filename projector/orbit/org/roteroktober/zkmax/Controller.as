import org.roteroktober.zkmax.util.Callback;
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.Cursor;
import org.roteroktober.zkmax.Alert;
import org.roteroktober.zkmax.Autopilot;
import org.roteroktober.zkmax.util.Deferred;
import org.roteroktober.zkmax.model.Tag;
import org.roteroktober.zkmax.model.Entry;
import org.roteroktober.zkmax.model.Person;
import org.roteroktober.zkmax.model.Comment;

import mx.remoting.debug.NetDebug;
import mx.remoting.Service;
import mx.remoting.PendingCall;
import mx.rpc.RelayResponder;

class org.roteroktober.zkmax.Controller {

    private static var controller:Controller;

    public static var SERVER_URL:String = "http://projector.castro.local/";    
    public static var WOBBLE_HOST:String = "projector.castro.local";
    private var _tags:Array = new Array();
    
    public var autopilot:Autopilot; 
    
    private var service:Service; 
    private static var filesocket:Object;
    private static var btsocket:XMLSocket;
    private static var keylistener:Object;
    
    static var LEFT:Number = 1;
    static var UP:Number = 2;
    static var RIGHT:Number = 3;
    static var DOWN:Number = 4;
    static var FIRE:Number = 5;
    static var CODES_KB:Object = new Object();
    static var CODES_BT:Object = new Object();

    private function Controller()
    {
        var gatewayURL:String = SERVER_URL + "gateway/";
        service = new Service(gatewayURL, null, "Orbit", null, null);
        autopilot = new Autopilot();
        
        // code mapping
        CODES_KB[Key.LEFT] = LEFT;
        CODES_KB[Key.UP] = UP;
        CODES_KB[Key.RIGHT] = RIGHT;
        CODES_KB[Key.DOWN] = DOWN;
        CODES_KB[Key.SPACE] = FIRE;
        CODES_BT[1] = FIRE;    
        CODES_BT[2] = UP;
        CODES_BT[3] = LEFT;
        CODES_BT[4] = DOWN;
        CODES_BT[5] = RIGHT;
        Object.registerClass("org.roteroktober.zkmax.model.Entry",Entry);
        Object.registerClass("org.roteroktober.zkmax.model.Tag",Tag);
        Object.registerClass("org.roteroktober.zkmax.model.Person",Person);
        Object.registerClass("org.roteroktober.zkmax.model.Comment",Comment);
    }


    public function get tags():Object
    {
        if(!_tags._length) {
            return new Deferred("getTags","onLoadedTags");
        } else {
            return _tags;
        }
    }

    public function onLoadedTags(evt:Object):Object
    {
        trace(" hit!! ")
        var n:Number = 0;
        for(;n<evt.__result.length;n++) {
            var tag:Tag = evt.__result[n];
            tag.checkWeight();
            _tags[tag.id] = tag;
        }
        _tags._length = n;
        return _tags;
    }

    public function onError(evt:Object) {
        trace(evt.__fault.__type)
        trace(evt.__fault.__detail)
        trace(evt.__fault.__faultstring)
        trace(evt.__fault.__faultcode)
    };

    public function sendWobbleFiles(files:Object){
        sendWobble("FILES|"+files.join("|"))
    }
    
    public function sendWobble(msg:String)
    {
        setupWobbleConnection()
        filesocket.send(msg+"\n");            
    }

    private function setupWobbleConnection()
    {
        if(!filesocket) {
            trace("setup connection to mini")
            filesocket = new XMLSocket();
            filesocket.onData = function (src) {
                this.connected = true;
                trace("received from mini: " + src);
                switch(src) {
                    case "DONE":
                        var alert:Alert = new Alert("wobble says 'done displaying'");
                        break;
                    case "CONNECTED":
                        var alert:Alert = new Alert("now connected to the wobble movie!");
                        break;
                }
            }
            filesocket.onClose = function () {
                this.connected = false;
            }
        } 
        if(!filesocket.connected) {
            trace("connect to mini")
            // broadcaster
            filesocket.connect(Controller.WOBBLE_HOST,9999); 
            filesocket.send("PROJECTOR\n");
        }
    }
    
    public function setupConnection()
    {
        // listeners
        keylistener = new Object();
        keylistener.onKeyUp = function() {
            Controller.getController().handleDirection(Controller.CODES_KB[Key.getCode()]);
        };
        // an xmlsocket locally defined crashes the player
        btsocket = new XMLSocket();
        btsocket.onData = function (src) {
            trace("received from bridge: " + src);
            Controller.getController().autopilot.idle();
            switch(src.substring(0,1)) {
                case "A":
                    var alert:Alert = new Alert(src.substring(2));
                break;
                case "F":
                    Controller.getController().handleFile(src.substring(2));
                break;
                case "D":
                    Controller.getController().handleDirection(Controller.CODES_BT[src.substring(2)]);
                break;      
            }
        }
        // broadcaster
        Key.addListener(keylistener);
        btsocket.connect("127.0.0.1",6666);  
    }

    public function handleDirection(direct:Number) {   
        switch(direct) {
            case UP:    
                Cursor.getInstance().move(0,-1);                
            break;
            case DOWN:
                Cursor.getInstance().move(0,1);             
            break;
            case LEFT:
                Cursor.getInstance().move(-1,0);                
            break;
            case RIGHT:
                Cursor.getInstance().move(1,0);             
            break;
            case FIRE:
                Cursor.getInstance().click();               
            break;
        }
    }
    

    public function handleFile(file:String) {
        var node = Canvas.getInstance().getActualNode();
        var d:Deferred = new Deferred(["setFile",[file,node]],"onSetFile");
        d.addCallback(new Callback("displayFile",this));
    }

    public function onSetFile(evt:Object):Comment
    {
        return evt.__result;
    }

    public function displayFile(comment:Comment)
    {
        var alert:Alert = new Alert("A Gotchi has been added and uploaded to www.orbit.zkm.de!",comment.filename);
        comment.setPath();
        Canvas.getInstance().addComment(comment);
    }
    
    public function getService():Service
    {
        return service;
    }
    
    public static function getController():Controller 
    {
        if(controller==undefined){
            controller = new Controller();
        }
        return controller;
    }
    
    public static function main() {
        trace("Start Application"); 
        Canvas.getInstance().showTags();
    }

}   