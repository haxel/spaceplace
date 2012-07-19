//
//  VideoClip
//
//  Created by Axel Heide on 2006-05-22.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Presenter;

class org.roteroktober.zkmax.VideoClip {

    private var URL:String;
    private var length:Number;
    private var vid:MovieClip;
    private var presenter:Presenter;
    
    public function VideoClip(presenter:Presenter,url:String,length:Number){
        this.URL = url;
        this.presenter = presenter;
        if (length == 0) 
            this.length = 10000;
        else
            this.length = length;
    }

    function remove(){
        trace("stop VIDEO " + URL)
        _root.video_clip.attachVideo(null)
        presenter.netStream.close()
    }
    
    function playClip(){
        trace("play VIDEO " + URL + " : " +length)
        _root.video_clip.attachVideo(presenter.netStream);
        _root.pic_mc._visible = false;
        presenter.netStream.play(URL);
        return length
    };

};