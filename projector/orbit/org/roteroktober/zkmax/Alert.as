//
//  org.roteroktober.zkmax.Alert
//
//  Created by Axel Heide on 2006-05-17.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//


/*
 Display messages on screen (comments arrive / user is remoting / disconnecting ...)
*/

class org.roteroktober.zkmax.Alert {

    private static var root:MovieClip = _root;
    private static var z:Number = 220;

    private static var alerts:Array = new Array();

    public var mc:MovieClip;

    private var message:String;
    private var filename:String;
    private var timeout:Number;
    
    public function Alert(message:String,filename:String){
        this.filename = filename;
        this.message = message;
        Alert.push(this);
    };
    
    public function dismiss() {
        clearInterval(timeout);
        Alert.pop();
    }
    
    private static function push(alert:Alert){
        if(Alert.alerts.length > 6) {
            Alert.pop(alert);
            return;
        }
        Alert.alerts.push(alert);
        alert.mc = root.attachMovie("assets.alert","alert_"+alerts.length,z+alerts.length);
        alert.mc._x = 0;
        alert.mc._y = (Alert.alerts.length * 128);
        alert.mc.message.text = alert.message;
        if (alert.filename) {
            alert.mc.img.loadMovie(alert.filename)
        }
        alert.timeout = setInterval(alert,"dismiss",5000);
    }
    
    public static function pop(addAlert:Alert){
        var a:Object = Alert.alerts.shift();
        a.mc.removeMovieClip();
        for(var x:Number=0;x<Alert.alerts.length;x++){
            Alert.alerts[x].swapDepths(z+x);
        }
        if(addAlert) Alert.push(addAlert);
    };

};