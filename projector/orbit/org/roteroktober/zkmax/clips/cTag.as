//
//  cEntry
//
//  Created by Axel Heide on 2006-05-02.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Cursor;
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.clips.cButton;

class org.roteroktober.zkmax.clips.cTag extends cButton {

    private var id:String;
    private var _idx:Number;
    private var _animationInterval:Number;
    public var gotchis:Array;
    public var scale;
    
    public function cTag(mc:MovieClip,name:String,id:String)
    {
        this.id = id;
        _idx = 0;
        gotchis = new Array();
        // onClick -> getTag 
        mc.name._visible = false;
        mc.name.text = name.toUpperCase(); //+ "\n" + col + ":" + row;
        super(mc,name,getTag)
    }

    public function getTag()
    {
        Canvas.getInstance().showTag(id);
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

	public function onCursorClick():Object
    {
        return (checkHit(_mc.act,null)) ? this : null;
    }

    public function setGotchi(id:String){
        for(var n in gotchis) {
            if(gotchis[n].id==id) return;
        }
        var gotchi = "gotchi_" + id;
        if(_mc.content_mc) {
            var gmc = _mc.content_mc.attachMovie(gotchi,gotchi+"_mc",gotchis.length + 10);
            gmc.id = id;
            if(gmc)
            {
                gmc._x = -64;
                gmc._y = -64;
                gmc._visible = false;
                gotchis.push(gmc);
            }
        }
    }

    public function startAnimating()
    {
        gotchis[0]._visible = true;
        if(gotchis.length>1)
        {
            _animationInterval = setInterval(this, "stepAnim", Math.ceil(Math.random()*10) * 1000)
        }
    };

    public function stepAnim()
    {
        if(_idx++ > gotchis.length) _idx = 0;
        for(var n in gotchis){
            gotchis[n]._visible = false;
        }
        gotchis[_idx]._visible = true;
    }

    public function onEnter():Void
    {
        _mc.frame_mc.onEnter();
        if(!scale) scale = _mc.content_mc._xscale;
        _mc.content_mc._xscale = 100;
        _mc.content_mc._yscale = 100;
        _mc.content_mc._alpha = 50;
        _mc.name._visible = true;
    }
    	
    public function onLeave():Void
    {
        _mc.frame_mc.onLeave();
        if(!scale) scale = _mc.content_mc._xscale;
        _mc.content_mc._xscale = scale;
        _mc.content_mc._yscale = scale;
        _mc.content_mc._alpha = 100;
        _mc.name._visible = false;
    }

};