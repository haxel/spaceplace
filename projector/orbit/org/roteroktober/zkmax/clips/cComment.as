//
//  cComment
//
//  Created by Axel Heide on 2006-05-03.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//

import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.clips.cButton;

class org.roteroktober.zkmax.clips.cComment extends cButton {
    private var id:String;
    private var showme:Boolean;

    public function cComment(mc:MovieClip,name:String,id:String)
    {
        this.id = id;
        showme = false;
        super(mc,name,getComment)
    }

    public function loadImage(filename:String)
    {
        var li:Object = new Object();
        li.onLoadInit = function(targetMC:MovieClip) {
            targetMC._xscale = 60;
            targetMC._yscale = 60;
            targetMC._x = (128 - targetMC._width) / 2;
            targetMC._y = (128 - targetMC._height) / 2;
        }
        var l:MovieClipLoader = new MovieClipLoader();
        l.addListener(li);
        l.loadClip(filename,mc.content_mc);
    }

    public function getComment()
    {
        //Canvas.getInstance().showComment(id);            
        if(showme) {
            showme = false;
            mc.gotoAndStop(1)
        } else {
            showme = true;
            mc.gotoAndStop(2)
        }
            
    }

    public function checkHit(hitMc:MovieClip,point:Object):Boolean
    {
        var pos:Object = Canvas.getInstance().getPosition(point);
        var p:Object = {x:pos.x *128,y:pos.y *128}
        // it is always a square!
        if((p.x==_mc._x+_mc._parent._x) &&
           (p.y==_mc._y+_mc._parent._y)) {
               return true;
        } else {
            return false;
        }
    } 


};