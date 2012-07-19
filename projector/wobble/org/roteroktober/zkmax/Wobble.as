import org.roteroktober.zkmax.Presenter;
import org.roteroktober.zkmax.VideoClip;
import org.roteroktober.zkmax.Ticker;

class org.roteroktober.zkmax.Wobble {

    private static var instance:Wobble; 
                                                     
    private var filesocket:Object; 
    private var delay:Number; 
    private var presenter:Presenter; 
    private var tickers:Array; 
    private var ticker_playing:Number = 0; 
    
    private static var host = "mini1";                  
    
    private function Wobble()
    {
        instance = this;
        presenter = new Presenter();
        tickers = new Array();
    } 

    public function idle(timeoutMS:Number) 
    {
        clearInterval(delay);
        delay = setInterval(presenter,"playFile",timeoutMS);
    }

    public function pause(video:VideoClip) 
    {
        clearInterval(delay);
    }

    public function showNextTicker(){
        trace("showNextTicker")
        var t:Ticker = tickers[ticker_playing];
        t.draw(_root.ticker_mc);
        if(ticker_playing++ > tickers.length) ticker_playing = 0;
    }
    
    public function cont() 
    {
       presenter.playFile()
    }
    
    public function addNews(title:String,body:String)
    {
        var t:Ticker = new Ticker(title,body);
        tickers.push(t);
    }
    
    public function addFiles(files:Array)
    {
        presenter.reset()
        for ( var n=0; n<files.length; n++ ) {
            switch(files[n].substr(-3))
            {
                case "flv":
                    presenter.addMovie("http://" + host + "/movies/" + files[n].substr(9),new Number(files[n].substr(0,8)));
                    break;
                case "jpg":
                    presenter.addImage("http://" + host + "/images/" + files[n]);
                    break;
            }
        };
        presenter.playFile()
    }

    private function setupConnection(host:String)
    {
        trace("setup")
        if(!filesocket) {
            trace("setup connection to mini")
            filesocket = new XMLSocket();
            filesocket.onConnect = function (success:Boolean) {
                this.connected = success;
                this.send("WOBBLE\n");
                trace("connected");
            }            
            filesocket.onData = function (src) {
                this.connected = true;
                var cmd = src.substring(0,5);
                trace("received from mini: " + cmd);
                
                switch(cmd) {
                    case "FILES":
                        Wobble.getInstance().addFiles(src.substring(6).split("|"))
                        break;
                    case "CONNE":
                        trace("now connected")
                        break;
                    case "<news":
                        var news = new XML();
                        news.ignoreWhite = true;
                        news.parseXML(src);
                        var w:Wobble = Wobble.getInstance();
                        for ( var n=0; n<news.firstChild.childNodes.length; n++ ) {
                            w.addNews(news.firstChild.childNodes[n].childNodes[0].firstChild.nodeValue,
                                      news.firstChild.childNodes[n].childNodes[1].firstChild.nodeValue);                            
                        };
                        
                        if(w.ticker_playing == 0) w.showNextTicker();
                        break;
                }
            }
            filesocket.onClose = function () {
                this.connected = false;
            }
        } 
        if(!filesocket.connected) {
            trace("connect to " + host)
            // broadcaster
            filesocket.connect(host,9999);
        }
    }
    
    public function sendWobble(msg:String)
    {
        setupConnection()
        filesocket.send(msg+"\n");            
    }
    
    public static function getInstance()
    {
        if(!instance) instance = new Wobble()
        return instance;
    }
    
    public static function main()
    {       
        Wobble.getInstance().setupConnection(host);
    }

};