//
//  org.roteroktober.zkmax.model.Entry
//
//  Created by Axel Heide on 2006-04-26.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//

import org.roteroktober.zkmax.util.Deferred;
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.Controller;
import org.roteroktober.zkmax.model.IClickable;
import org.roteroktober.zkmax.model.Person;
import org.roteroktober.zkmax.model.Tag;

class org.roteroktober.zkmax.model.Entry implements IClickable {

    public var id:String;
    public var name:String;
    public var body:String;
    public var teaser:String;
    public var authorID:String;
    public var files:Array;
    public var author:Person;

    public var mc:String; 

    public function Entry(id:String,title:String,uid:String) 
    {
        if(!this.id) {
            this.id = id;
            this.name = title;
            this.authorID = uid;
        }
    }

    public static function getComplete(id:String):Object
    {
        var entry = new Entry(id);
        return new Deferred(["getEntry",id],"onLoaded",null,entry);
    }

    public function getFiles():Object
    {
        if(!files)
            return new Deferred(["getFilesOfEntry",id],"onLoadedFiles",null,this);
        else 
            return files
    }

    public function get tags():Object
    {
        return new Deferred(["getTagsByEntry",id],"onLoadedTags",null,this);
    }

    public function get comments():Object
    {
        return new Deferred(["getComments",id],"onLoadedComments",null,this);
    }

    public function onLoadedTags(evt:Object)
    {
        var tags = new Array();
        for(var n:Number=0;n<evt.__result.length;n++) {    
            tags.push(Controller.getController().tags[evt.__result[n].id]);
        }  
        return tags;
    }

    public function onLoadedComments(evt:Object)
    {
       var comments:Array = new Array();
        for(var n:Number=0;n<evt.__result.length;n++) {    
            comments.push(evt.__result[n]);
        }  
       return comments;           
    }

    public function onLoadedFiles(evt:Object)
    {
        files = new Array();
        for(var n:Number=0;n<evt.__result.length;n++) {    
            files.push(evt.__result[n]);
        }  
       return files;           
    }

    public function onLoaded(evt:Object)
    {
        var entry:Entry = evt.__result;
        trace(entry)
        this = entry;
        authorID = entry.author.id;
        return this;   
    }
    
    public function onClick():Void{}

    public function onEnter():Void
    {
         var tag_mc = Canvas.getInstance().root[mc];
         tag_mc.frame_mc.onEnter();
         tag_mc.name._visible = true;
    }
    public function onLeave():Void
    {
         var tag_mc = Canvas.getInstance().root[mc];
         tag_mc.frame_mc.onLeave();
         tag_mc.name._visible = false;        
    }
    
};