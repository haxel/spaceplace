//
//  org.roteroktober.zkmax.clips.Comments
//
//  Created by Axel Heide on 2006-04-26.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.util.Callback;
import org.roteroktober.zkmax.clips.cButton;
import org.roteroktober.zkmax.clips.cComment;
import org.roteroktober.zkmax.Alert;

class org.roteroktober.zkmax.clips.cComments extends cButton{
    
    private var _items:Array;
    private var _mc:MovieClip;
    private var cols = 0;
    
    public function cComments(mc:MovieClip,name:String)
    {
        super(mc,name);
        _items = new Array();        
    }


    public function addItems(items:Object){
        if(items.isDeferred) {
            items.addCallback(new Callback("pushItems",this));            
        } else {
            pushItems(items);            
        }        
    }

    public function get active(check:Boolean){
        return _active;
    }

    public function set active(check:Boolean){
        for ( var i=0; i<_items.length; i++ ) {
            _items[i].active = check;
        }
        _active = check;
    }

    public function pushItem(item:Object):cComment{
        var c:Number = _items.length;            
        var mc:MovieClip = _mc.comment.duplicateMovieClip("tag_"+c,_mc.getNextHighestDepth());
        var t = item.comment.split("\n")
        if(t) {
            mc.title.text = t[0]; //item.filename;
            if(t.length>=1) mc.comment.text = t[1]; //item.filename;
        }
        var lastX = (_items.length>0) ? _items[_items.length-1].mc._x : 0;
        
        trace(lastX);
        
        if(lastX == 512) {
            cols++;
            if(cols == 5) {
                //
            }
            mc._x = 0;
        } else {
            mc._x = lastX + 128;
        }
        mc._y = -cols * 128;
        var btn:cComment = new cComment(mc,item.name,item.id);
        btn.loadImage(item.filename);
        _items.push(btn)   
        //onMouseOver();         
        active = true;
        return btn;
    }

    public function pushItems(items:Object){
        for ( var i=0; i<items.length; i++ ) {
            pushItem(items[i])
            /*
            var c:Number = _items.length;            
            var mc:MovieClip = _mc.comment.duplicateMovieClip("tag_"+c,i+10);
            mc.title.text = items[i].filename;
            mc._x = (c+1) * 128;
            var btn = new cComment(mc,items[i].name,items[i].id);
            _items.push(btn)            
            */
        };
        active = false;
    }

    public function onCursorMove(evt:Object):Object
    {
        if(active) {
            for ( var i=0; i<_items.length; i++ ) {
                var btn = _items[i].onCursorMove(evt);
                if(btn) {
                    _items[i].onMouseOver()
                    return btn;
                }
            }
            if(checkHit(_mc.moreComments_mc,evt)) {
                // display comments
                onMouseOver();
                return this;                
            } 
        } else {
            if(checkHit(_mc.moreComments_mc,evt)) {
                onMouseOver();
                return this;                
            }
        } 
        return null;
    }

    public function onCursorClick():Object
    {
        if(checkHit(_mc.moreComments_mc,null)) {
            active = !active;
            if(active)
                var alert:Alert = new Alert("To upload a comment gotchi use the bluetooth client");
            
            return this;
        } else {
            for ( var i=0; i<_items.length; i++ ) {
                var btn = _items[i].onCursorClick();
                if(btn) {                    
                    //active = false;
                    return btn;
                }
            }
            return null;
        }
    }

}