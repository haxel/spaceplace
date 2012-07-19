//
//  cButton
//
//  Created by Axel Heide on 2006-05-02.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Cursor;
import org.roteroktober.zkmax.Canvas;

class org.roteroktober.zkmax.clips.cButton {
    
    private var _mc:MovieClip;
    public var name:String;
    public var handler:Function;
    private var _active:Boolean;
    
    public function cButton(mc:MovieClip,name:String,handler:Function)
    {
        _mc = mc;
        this.name = name;
        this.handler = handler;
        _mc.act = _mc.hitArea_mc;
    }

    public function checkHit(hitMc:MovieClip,point:Object):Boolean
    {
        var pos:Object = Canvas.getInstance().getPosition(point);
        var p:Object = {x:pos.x *128,y:pos.y *128}

        if((p.x>=_mc._x + hitMc._x && p.x <= _mc._x + hitMc._x + hitMc._width - 128) &&
           (p.y>=_mc._y + hitMc._y && p.y <= _mc._y + hitMc._y + hitMc._height - 128)) {
               return true;
        } else {
            return false;
        }
    } 

    public function get mc(){
        return _mc;
    }

    public function get active(check:Boolean){
        return _active;
    }

    public function set active(check:Boolean){
        _mc._visible = check;
        _active = check;
    }

    public function onMouseOver()
    {
        trace(name + " was moused!")
    }
        
	public function onCursorMove(evt:Object):Object
    {
        if (checkHit(_mc.act,evt)) 
        {
            onMouseOver();
            return this;
        } else {
            return null;            
        }
    }

	public function onCursorClick():Object
    {
        return (checkHit(_mc.act,null)) ? this : null;
    }

}