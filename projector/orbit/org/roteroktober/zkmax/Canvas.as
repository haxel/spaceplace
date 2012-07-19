//
//  org.roteroktober.zkmax.Canvas
//
//  Created by Axel Heide on 2006-04-26.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//

import org.roteroktober.zkmax.Controller;
import org.roteroktober.zkmax.Cursor;
import org.roteroktober.zkmax.Alert;
import org.roteroktober.zkmax.model.IClickable;
import org.roteroktober.zkmax.model.Entry;
import org.roteroktober.zkmax.model.Comment;
import org.roteroktober.zkmax.model.Tag;
import org.roteroktober.zkmax.util.Textformat;
import org.roteroktober.zkmax.util.Callback;
import org.roteroktober.zkmax.clips.*;

class org.roteroktober.zkmax.Canvas {

    public static var TAGS:Number = 1;
    public static var TAG:Number = 2;
    public static var PERSON:Number = 3;

    private static var canvas:Canvas;

    public var root:MovieClip;
    public var root_tags:MovieClip;
    public var root_tag:MovieClip;
    public var root_entry:MovieClip;
    
    public var state:Number;
    private var posX:Number;
    private var posY:Number;    
    private var activeElem:MovieClip;

    private var node:String;
    
    private var entryButtons:Array;
    
    private function Canvas()
    {
        // setup the 3 planes - tags / tag / entry
        root_entry = _root.createEmptyMovieClip("entry_mc",10);
        root_tag = _root.createEmptyMovieClip("tag_mc",5);
        root_tags = _root.createEmptyMovieClip("tags_mc",4);
        // root is a reference to the visible plane
        root = root_tags

        // a splash movie
        _root.attachMovie("assets.splash","splash_mc",_root.getNextHighestDepth());    
        
        // set the cursor
        var cursor:Cursor = Cursor.getInstance();
        cursor.addEventListener("onCursorMove",this);
        cursor.addEventListener("onCursorClick",this);        
        
    }

    public function showEntry(id:String) 
    {
         Entry.getComplete(id).addCallback(new Callback("displayEntry",this));            
    }

    public function addComment(comment:Comment)
    {
        if(state==PERSON) {
            var com:Object;
            for(var n in entryButtons){
                if(entryButtons[n].name == "Comments") {
                    com = entryButtons[n];
                    break;
                }
            }
            if(com) {
                com.pushItem(comment);
            }
        }
    }

    public function showComments(comments:Object)
    {        
        for ( var n=0; n<comments.length; n++ ) {
            comments[n].setPath();
        };
        var com:cComments = new cComments(root_entry.entry_mc.comments_mc,"Comments");
        com.addItems(comments)
        entryButtons.push(com);
    };

    public function showAuthor(author:Object,altName:String)
    {
        var entries:cEntries = new cEntries(root_entry.entry_mc.entries_mc,"Entries");
        entries.addItems(author.entries)
        entryButtons.push(entries);
        root_entry.entry_mc.author_mc.attachMovie("gotchi_"+author.id,"person",1);
        root_entry.entry_mc.authorName_txt.text = (altName) ? altName.toUpperCase() : author.name;
        if(author.profile.isDeferred()) 
            author.profile.addCallback(new Callback("displayProfile",this,[false]));
        else
            displayProfile(author.profile,false)
    }
    
    public function showTagsOfEntry(c:Object)
    {
        var tags:cTags = new cTags(root_entry.entry_mc.tags_mc,"Tags");
        tags.addItems(c)
        entryButtons.push(tags);
    }
    
    public function showTags() 
    {
        var c:Object = Controller.getController().tags;
        if(c.isDeferred) {
           c.addCallback(new Callback("displayTags",this));
        } else {
           displayTags(c);
        }
    }
        
    public function showTag(id:String) 
    {
        var tag:Tag = Controller.getController().tags[id]; 
        // always a deffered
        tag.entries.addCallback(new Callback("displayTag",this,[tag]));
    }

    public function showProfile(author:Object) 
    {
        if(root_entry.entry_mc.profile_out_mc._visible == false) {
            if(author.profile.isDeferred()) 
                author.profile.addCallback(new Callback("displayProfile",this,[true]));
            else
                displayProfile(author.profile,true)
        }
        else 
            hideProfile()
    }

    public function hideProfile() 
    {
        root_entry.entry_mc.body_mc._visible = true;
        root_entry.entry_mc.profile_out_mc._visible = false;
    }

    public function displayProfile(profile:Object,extended:Boolean) 
    {
        if(extended)
        {
            root_entry.entry_mc.body_mc._visible = false;
            root_entry.entry_mc.profile_out_mc._visible = true;
            renderText(profile['about'],root_entry.entry_mc.profile_out_mc)
        }
        root_entry.entry_mc.profileBase_txt.text = profile['base']
        root_entry.entry_mc.profileFaves_txt.text = profile['moons']
        root_entry.entry_mc.profilePath_txt.text = profile['path']
        root_entry.entry_mc.profileSign_txt.text = profile['sign']
    }
    

    private function scrollBody() {
        root_entry.endTimerAt -= 19.4;
        if(root_entry.endTimerAt > 0) {
            root_entry.entry_mc.body_mc.bodytext._y -= 19.4;
        } else {
            clearInterval(root_entry.timer)
        }
    }
    
    private function renderText(text:String,mc:MovieClip)
    {
        mc.bodytext.htmlText = Textformat.stripText(text) 

        var maxHeight = mc.bodytext.textHeight
        var n=1
        var lmc;
        
        if(maxHeight > 400) {
            root_entry.timer = setInterval(this,"scrollBody",3000);
            root_entry.endTimerAt = maxHeight - 400;
        }
        while(maxHeight>0) {
            lmc = mc.gitter.line_mc.duplicateMovieClip("line"+n,n);
            lmc._y = 19.4 * n;
            maxHeight -= 19.4;
            n++
        }
    }
    
    private function displayEntry(entry:Object) 
    {
        resetRoot(root_entry);

        node = entry.id;
        entryButtons = new Array();
        entryButtons.push(new cButton(root_entry.entry_mc.profile_mc,"Profile",function() {Canvas.getInstance().showProfile(entry.author);}));
        entryButtons.push(new cButton(root_entry.entry_mc.back_mc,"Back",function() {Canvas.getInstance().showTags();}));
        entryButtons.push(new cButton(root_entry.entry_mc.entry_mc,"Entry"));

        var name = entry.name;
        var altName = name.substr(0,name.indexOf("«"));
        root_entry.entry_mc.entryTitle_txt.text = name.slice(name.indexOf("«")+1,name.indexOf("»")).toUpperCase();
        root_entry.entry_mc.entryTitle_alttxt.text = name.slice(name.indexOf("»")+1);
        
        renderText(entry.body,root_entry.entry_mc.body_mc)
        
        showAuthor(entry.author,altName);
        entry.tags.addCallback(new Callback("showTagsOfEntry",this));            
        entry.comments.addCallback(new Callback("showComments",this));
        var files = entry.files
        if(files.isDeferred())
        {
            files.addCallback(new Callback("sendWobbleFiles",Controller.getController()))
        } else {
            Controller.getController().sendWobbleFiles(files);
        }
        root_entry.entry_mc.profile_out_mc._visible = false;
        
        posX = 1;
        posY = 4;
        
        state = PERSON                
         setPosition(0,0);
   }

    private function displayTag(entries:Object,tag:Tag) 
    {
        trace(tag)
        var alert:Alert = new Alert(tag.name);
        var offset:Object = {x:root_tags._x/128,y:root_tags._y/128};
        var oldpos:Object = {x:posX,y:posY};
        resetRoot(root_tag)
        var width:Number = Math.floor(Math.sqrt(entries.length+1));

        var x:Number = 0;
        var y:Number = 0;
        var col:Number = 0;
        var row:Number = 0;
                
        for ( var n:Number=0; n<entries.length; n++ ) {
            entries[n].mc = "mc_" + col + "_" + row
            var mc:MovieClip = root_tag.attachMovie("assets.tagentry",entries[n].mc,root_tag.getNextHighestDepth());
            /*if( n == entries.length) 
            {
                mc.name.text = "BACK\n" + col + ":" + row;                
                mc.instance = null;                
            }
            else {*/
                var name = entries[n].name;
                mc.name.text = name.substr(0,name.indexOf("«"));
                mc.titel.text = name.slice(name.indexOf("«")+1,name.indexOf("»"));
                var gotchi = "gotchi_" + entries[n].authorID
                var gotchi_mc = mc.content_mc.attachMovie(gotchi,gotchi+"_mc",1);
                if(gotchi_mc)
                {
                    gotchi_mc._x = -64;
                    gotchi_mc._y = -64;
                } else {
                    trace("can not find " + gotchi)
                }
                mc.instance = entries[n];                                
            //}
            //mc.name._visible = false;
            //mc.titel._visible = false;
            mc._x = col*128;
            mc._y = row*128;
            if(col++>=width) 
            {
                col = 0;
                row++;
            }
        };
        var newpos = {x:Math.floor(width / 2),y:Math.floor(width / 2)}
        setRootPos(oldpos.x-newpos.x+offset.x,oldpos.y-newpos.y+offset.y)        
        posX = newpos.x;
        posY = newpos.y;
        state = TAG        
        setPosition(0,0);
    }
    
    private function displayTags(tags:Object)
    {
        var alert:Alert = new Alert("ART IN THE AGE OF ORBITALIZATION");
        resetRoot(root_tags);
        var width:Number = Math.ceil(Math.sqrt(tags._length));
        if(_root.splash_mc) {
            _root.splash_mc.removeMovieClip();
            var ctrl:Controller = Controller.getController();
            ctrl.setupConnection(); 

            var x:Number = 0;
            var y:Number = 0;
            var col:Number = 0;
            var row:Number = 0;
            for ( var n in tags ) 
            {
                tags[n].mc = "mc_" + col + "_" + row
                var mc = root_tags.attachMovie("assets.tag",tags[n].mc,root_tags.getNextHighestDepth());

                mc._x = col*128;
                mc._y = row*128;
                if(col++>width) 
                {
                    col = 0;
                    row++;
                }
                var scale:Number = (tags[n].weight / Tag.MAX_WEIGHT) * 100;
                mc.content_mc._xscale = scale;
                mc.content_mc._yscale = scale;

                var btn = new cTag(mc,tags[n].name,tags[n].id);
                
                for(var j in tags[n].gotchis) 
                {
                    btn.setGotchi(tags[n].gotchis[j]);
                }
                btn.startAnimating();    
                
                mc.instance = btn
            };    
        } 
        else 
        {
            onLeaveBtns()
        }
        setRootPos(-Math.floor((width - 8) / 2 ),-Math.floor((width - 6) / 2 ))
        posX = Math.floor(width / 2)
        posY = Math.floor(width / 2)
        setPosition(0,0);
        state = TAGS        
    }

    private function onLeaveBtns()
    {
        for (var n in root) {
            root[n].onLeave();    
        }
    }

    private function resetRoot(mc:MovieClip)
    {
        clearInterval(root_entry.timer);
        switch(mc) {
            case root_tags:
                root_entry._visible = false;
                root_tags._visible = true;
                root_tag._visible = false;
                root = root_tags
            break;
            case root_tag:
                root_tag = _root.createEmptyMovieClip("tag_mc",5);
                root_entry._visible = false;
                root_tags._visible = false;
                root_tag._visible = true;
                root = root_tag
            break;
            case root_entry:
                root_entry = _root.createEmptyMovieClip("entry_mc",10);
                root_entry.attachMovie("assets.entry","entry_mc",1);    
                root_entry._visible = true;
                root_tags._visible = false;
                root_tag._visible = false;
                root = root_entry
            break;
        }
    }

    public function getPosition(p:Object)
    {
        if(p) {
            return {x:posX + p.x,y:posY + p.y}
        } else {            
            return {x:posX,y:posY}
        }
    }
    
    private function setRootPos(x:Number,y:Number)
    {
        root._x = x * 128;        
        root._y = y * 128;    
    }

    private function checkLimit()
    {
        if(root._x + activeElem._x < 128) 
        {
            root._x += 128
        }
        else if(root._x + activeElem._x == 896 )
        {
            root._x -= 128
        }
        if(root._y + activeElem._y < 128) 
        {
            root._y += 128;
        } 
        else if(root._y + activeElem._y == 640 )
        {
            root._y -= 128;            
        }
    }

    public function setHighlight(x:Number,y:Number):MovieClip
    {
        var mc:MovieClip = root["mc_" + x + "_" + y];
        if(mc != undefined) {
            activeElem.instance.onLeave() 
            activeElem = mc;
            activeElem.instance.onEnter() 
            return mc;
        }            
        return null;
    }

    public function getActualNode(){
        if(state == PERSON) return node;
        return null;
    }

    public function setPosition(x:Number,y:Number)
    {
        var newx:Number =  posX + x;
        var newy:Number =  posY + y;
        if(state!=PERSON) {
            var mc:MovieClip = setHighlight(newx,newy);
            if(mc != undefined) {
                checkLimit();
                posX = newx;
                posY = newy;
            }            
        } else {
            posX = newx;
            posY = newy;            
        }
        Cursor.getInstance().draw(getAbsolutePos())    
    }

    public function onCursorClick()
    {
        switch(state) {
            case TAGS:
                var mc:MovieClip = root["mc_" + posX + "_" + posY];        
                showTag(mc.instance.id);                
            break;
            case TAG:
                var mc:MovieClip = root["mc_" + posX + "_" + posY];        
                if(!mc.instance)
                    showTags();                
                else
                    showEntry(mc.instance.id);                
            break;
            case PERSON:
                for ( var n=0; n<entryButtons.length; n++ ) {
                    var btn = entryButtons[n].onCursorClick();
                    if(btn)
                    {
                        btn.handler()
                        break;
                    };
                };
                break;
          }
    };
    
    private function getAbsolutePos():Object{
        var offset:Object = {x:root._x/128,y:root._y/128};
        return {x:posX+offset.x,y:posY+offset.y}
    }
    
    // listener vor cursor events
    public function onCursorMove(evt:Object)
    {        
        switch(state) {
            case PERSON:
                var found = false;
                for ( var n=0; n<entryButtons.length; n++ ) {
                    var btn = entryButtons[n].onCursorMove(evt);
                    if(btn)
                    {
                        found = true;
                    };
                };
                if(found) {
                    setPosition(evt.x,evt.y);
                }
                break;                
            default:
                setPosition(evt.x,evt.y);
                var p:Object = getPosition()
        }
    }

    public static function getInstance():Canvas
    {
        if(canvas==undefined){
            canvas = new Canvas();
        }
        return canvas;
    }
    

};