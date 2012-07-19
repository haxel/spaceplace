//
//  Presenter
//
//  Created by Axel Heide on 2006-05-22.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.ImageClip;
import org.roteroktober.zkmax.VideoClip;
import org.roteroktober.zkmax.Wobble;

class org.roteroktober.zkmax.Presenter {
    
    private var idx:Number = 0; 
    private var files:Array; 
    private var showing:Array; 

    public var netConn:NetConnection;
    public var netStream:NetStream;

    public var clip:Object;

    public function Presenter()
    {
        // NetConnection-Objekt erstellen:
        netConn = new NetConnection();
        // Lokale Streaming-Verbindung erstellen:
        netConn.connect(null);
        // NetStream-Objekt erstellen und onStatus()-Funktion definieren:
        netStream = new NetStream(netConn);
    }
    
    public function addImage(url:String)
    {
        files.push(new ImageClip(this,url));        
    } 

    public function addMovie(url:String,length:Number)
    {
        files.push(new VideoClip(this,url,length));        
    } 

    function reset()
    {
        files = new Array();
        idx = 0;
    }
    
    function playFile()
    {
    
        clip.remove()
        clip = files[idx];
        var delay = clip.playClip();
        Wobble.getInstance().idle(delay);
        if(files.length <= ++idx ) {
            idx = 0;
            Wobble.getInstance().sendWobble("DONE");
        }
    };
    
};