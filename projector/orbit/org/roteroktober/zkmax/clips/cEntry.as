//
//  cEntry
//
//  Created by Axel Heide on 2006-05-02.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.clips.cButton;

class org.roteroktober.zkmax.clips.cEntry extends cButton {

    private var id:String;

    public function cEntry(mc:MovieClip,name:String,id:String)
    {
        this.id = id;
        super(mc,name,getEntry)
    }

    public function getEntry()
    {
        Canvas.getInstance().showEntry(id);
    }
    
    public function showImage(files:Array)
    {
        var loadfile = ""
        for ( var n=0; n<files.length; n++ ) {
            if(files[n].substr(-3) == "jpg")
            {
                loadfile = files[n]
                break
            }
        };
        if (loadfile) {
            var clipLoaderListner = new Object();
            clipLoaderListner.onLoadInit = function(mc){
                mc._yscale = 32;
                mc._xscale = 32;
            } 
            var clipLoader = new MovieClipLoader();
            clipLoader.addListener(clipLoaderListner);
            clipLoader.loadClip("http://projector.castro.local/images/"+loadfile,mc.content_mc)
        }
    }

    public function checkHit(hitMc:MovieClip,point:Object):Boolean
    {
        var pos:Object = Canvas.getInstance().getPosition(point);
        var p:Object = {x:pos.x *128,y:pos.y *128}
        // it is always a square!
        if((p.x==_mc._x) &&
           (p.y==_mc._parent._y)) {
               return true;
        } else {
            return false;
        }
    } 

	public function onCursorClick():Object
    {
        return (checkHit(_mc.act,null)) ? this : null;
    }


};