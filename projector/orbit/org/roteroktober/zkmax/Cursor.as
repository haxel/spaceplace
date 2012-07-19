//
//  org.roteroktober.zkmax.Cursor
//
//  Created by Axel Heide on 2006-04-26.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//

import org.roteroktober.zkmax.Controller;
import mx.events.EventDispatcher;

class org.roteroktober.zkmax.Cursor {
    
    private static var cursor:Cursor;
    private var mc:MovieClip;
    
    function dispatchEvent() {};
    function addEventListener() {};
    function removeEventListener() {};    

    private function Cursor()
    {
        EventDispatcher.initialize(this);
    }

    public function draw(p:Object)
    {
        if(mc==undefined){
            mc = _root.attachMovie("assets.cursor","cursor_mc",20);
        }
        mc._x = p.x * 128
        mc._y = p.y * 128
    }
        
    public function click()
    {
        var eventObject:Object = {target:this,type:'onCursorClick'};  
        dispatchEvent(eventObject);        
    }
    
    public function move(x:Number,y:Number)
    {
        var eventObject:Object = {target:this,type:'onCursorMove'};  
        eventObject.x = x;    
        eventObject.y = y;    
        dispatchEvent(eventObject);
    }

    public static function getInstance():Cursor
    {
        if(cursor==undefined){
            cursor = new Cursor();
        }
        return cursor;
    }
    
};