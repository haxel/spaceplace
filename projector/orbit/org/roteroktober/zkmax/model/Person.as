//
//  org.roteroktober.zkmax.model.Person
//
//  Created by Axel Heide on 2006-04-26.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//

import org.roteroktober.zkmax.Controller;
import org.roteroktober.zkmax.model.IClickable;
import org.roteroktober.zkmax.util.Deferred;
import org.roteroktober.zkmax.util.Callback;
import org.roteroktober.zkmax.model.Entry;
import mx.remoting.PendingCall;
import mx.rpc.RelayResponder;
import mx.rpc.ResultEvent;
import mx.rpc.FaultEvent;

class org.roteroktober.zkmax.model.Person implements IClickable 
{
    public var id:String;
    public var img:String;
    public var name:String; 
    public var signature:String; 
    private var _profile:Object;
    
    public function Person(id:String) 
    {
        if(!this.id) this.id = id;
    }
    
    public function onLoadedPerson(evt:ResultEvent)
    {
        img = evt.result.img;
        name = evt.result.name;
        signature = evt.result.signature;
        return this;
    }

    public function onLoadedEntries(evt:ResultEvent)
    {
        var entries:Array = new Array();
        for ( var i=0; i<evt.result.length; i++ ) {
            var entry:Entry = new Entry(evt.result[i].id,evt.result[i].name,evt.result[i].authorID);
            entries.push(entry)
        };
        return entries;
    }

    public function onLoadedProfile(evt:ResultEvent)
    {
        _profile = evt.result
        return _profile;
    }

    public function get profile():Object
    {
        if(_profile==null)
            return new Deferred(["getProfileOfPerson",id],"onLoadedProfile",null,this);
        else 
            return _profile
    }

    public function get entries():Object
    {
        return new Deferred(["getEntriesOfPerson",id],"onLoadedEntries",null,this);
    }

    public function get mc():String
    {
        return "files/gotchi/picture-" + id + ".png";
    }

    public function getComplete():Object
    {
        if(!img) {
            return new Deferred(["getPerson",id],"onLoadedPerson",null,this);
        } else {
            return this;
        }
    }
    
    public function onClick():Void{}
    public function onEnter():Void{}
    public function onLeave():Void{}

};