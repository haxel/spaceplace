//
//  ImageClip
//
//  Created by Axel Heide on 2006-05-22.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Presenter;

class org.roteroktober.zkmax.ImageClip {

    private var URL:String;
    private var presenter:Presenter;
    
    public function ImageClip(presenter:Presenter,url:String){
        this.URL = url;
        this.presenter = presenter;
    }
    
    function remove(){
        trace("stop IMAGE " + URL)
        _root.pic_mc._visible = false;
    }

    function playClip(){
        trace("play IMAGE " + URL)
        var listener = new Object();
        listener.onLoadInit = function(mc)
        {
            mc._visible = true;
            mc._width = 1024;
            mc._height = 768;
        }
        var loader = new MovieClipLoader();
        loader.addListener(listener);
        loader.loadClip(URL,_root.pic_mc);
        return 10000;
    };

};