//
//  org.roteroktober.zkmax.model.Tag
//
//  Created by Axel Heide on 2006-04-26.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.Controller;
import org.roteroktober.zkmax.model.IClickable;
import org.roteroktober.zkmax.util.Deferred;
import org.roteroktober.zkmax.model.Person;
import org.roteroktober.zkmax.model.Entry;

class org.roteroktober.zkmax.model.Tag implements IClickable
{

    public static var MAX_WEIGHT:Number = 0; 

    public var mc:String; 
    
    public var gotchis:Array;
    public var id:String; 
    public var weight:Number; 
    public var name:String; 

    private var _idx:Number; 
    private var _animationInterval:Number; 
    public var scale:Number;
    

    public function checkWeight()
    {
        if(weight > MAX_WEIGHT) MAX_WEIGHT = weight;
    }

    public function get entries():Object
    {
        return new Deferred(["getEntriesForTag",id],"onLoadedEntries",null,this);
    }

    public function onLoadedEntries(evt:Object)
    {
        var entries = new Array();
        for(var n:Number=0;n<evt.__result.length;n++) {            
            entries.push(new Entry(evt.__result[n][1],evt.__result[n][2],evt.__result[n][3]));
        }     
        return entries;   
    }


    public function onClick():Void{}
    public function onEnter():Void
    {
/*         var tag_mc = Canvas.getInstance().root[mc];
         tag_mc.frame_mc.onEnter();
         if(!scale) scale = tag_mc.content_mc._xscale;
         tag_mc.content_mc._xscale = 100;
         tag_mc.content_mc._yscale = 100;
         tag_mc.name._visible = true;
*/    }
    public function onLeave():Void
    {
/*         var tag_mc = Canvas.getInstance().root[mc];
         tag_mc.frame_mc.onLeave();
         tag_mc.content_mc._xscale = scale;
         tag_mc.content_mc._yscale = scale;
         tag_mc.name._visible = false;        
*/    }
    
};