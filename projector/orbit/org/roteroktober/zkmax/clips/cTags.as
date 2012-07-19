//
//  cTags
//
//  Created by Axel Heide on 2006-05-02.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.clips.cButton;
import org.roteroktober.zkmax.clips.cTag;
import org.roteroktober.zkmax.util.Callback;

class org.roteroktober.zkmax.clips.cTags extends cButton{
    
    private var _items:Array;
    private var _mc:MovieClip;
    
    public function cTags(mc:MovieClip,name:String,handler:Function)
    {
        super(mc,name,null);
        _items = new Array();
    }

    public function addItems(items:Object){
        if(items.isDeferred) {
            items.addCallback(new Callback("pushItems",this));            
        } else {
            pushItems(items);            
        }        
    }

    public function pushItems(items:Object){
        
        for ( var i=0; i<items.length; i++ ) {
            var c:Number = _items.length;            
            var mc:MovieClip = _mc.attachMovie("assets.tag","tag_"+c,i+10);
            mc.name.text = items[i].name;
            mc._x = c * 128;
            mc.content_mc._xscale = 80;
            mc.content_mc._yscale = 80;
            var btn = new cTag(mc,items[i].name,items[i].id);
            for(var j in items[i].gotchis) {
                btn.setGotchi(items[i].gotchis[j]);
            }
            btn.startAnimating();
            _items.push(btn)            
        };
    }

    public function onCursorMove(evt:Object):Object
    {
       var btn = null;
        for ( var i=0; i<_items.length; i++ ) {
            if(!btn) btn = _items[i].onCursorMove(evt);
            _items[i].onLeave();
        }
        btn.onEnter();
        return btn;
    }

    public function onCursorClick():Object
    {
        for ( var i=0; i<_items.length; i++ ) {
            var btn = _items[i].onCursorClick();
            if(btn) {
                return btn;
            }
        }
        return null;
    }

}