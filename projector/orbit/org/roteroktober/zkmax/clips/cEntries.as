//
//  cEntries
//
//  Created by Axel Heide on 2006-05-02.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.clips.cButton;
import org.roteroktober.zkmax.clips.cEntry;
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.model.Entry;
import org.roteroktober.zkmax.util.Callback;

class org.roteroktober.zkmax.clips.cEntries extends cButton{
    
    private var _entries:Array;
    private var _mc:MovieClip;
    
    public function cEntries(mc:MovieClip,name:String)
    {
        super(mc,name);
        _entries = new Array();
    }

    public function addItems(entries:Object){
        if(entries.isDeferred) {
            entries.addCallback(new Callback("pushItems",this));            
        } else {
            pushItems(entries);            
        }        
    }

    public function get active(check:Boolean){
        return _active;
    }

    public function set active(check:Boolean){
        for ( var i=0; i<_entries.length; i++ ) {
            _entries[i].active = check;
        }
        _active = check;
    }
    
    public function pushItems(entries:Object){
        for ( var i=0; i<entries.length; i++ ) {            
            var c:Number = _entries.length;            
            var mc:MovieClip = _mc.entry.duplicateMovieClip("tag_"+c,i+10);
            var name = entries[i].name;
            //mc.name.text = name.substr(0,name.indexOf("«"));
            mc.title.text = name.slice(name.indexOf("«")+1,name.indexOf("»")).toUpperCase();
            mc.frame_mc._visible = false;
            mc._x = c * 128;
            var btn = new cEntry(mc,entries[i].name,entries[i].id);
            
            var files = entries[i].getFiles()
            if(files.isDeferred()) {
                files.addCallback(new Callback("showImage",btn))
            } else {
                btn.showImage(files);
            }
            
            _entries.push(btn)            
        };
        active = false;
    }

    public function getEntry(id:String)
    {
        Canvas.getInstance().showEntry(id);
    }

    public function onCursorMove(evt:Object):Object
    {
        if(active) {
            for ( var i=0; i<_entries.length; i++ ) {
                var btn = _entries[i].onCursorMove(evt);
                if(btn) {
                    _entries[i].onMouseOver()
                    return btn;
                }
            }
            if(checkHit(_mc.moreArea_mc,evt)) {
                onMouseOver();
                return this;                
            } 
        } else {
            if(checkHit(_mc.moreArea_mc,evt)) {
                onMouseOver();
                return this;                
            }
        } 
        return null;
    }

    public function onCursorClick():Object
    {
        if(checkHit(_mc.moreArea_mc,null)) {
            active = !active;
            return this;
        } else {
            for ( var i=0; i<_entries.length; i++ ) {
                var btn = _entries[i].onCursorClick();
                if(btn) {
                    active = false;
                    return btn;
                }
            }
            return null;
        }
    }

}