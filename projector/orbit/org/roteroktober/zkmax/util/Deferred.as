//
//  Deferred
//
//  Created by Axel Heide on 2006-01-19.
//  Copyright (c) 2006 Rokt. All rights reserved.
//

import mx.remoting.PendingCall;
import mx.rpc.RelayResponder;
import org.roteroktober.zkmax.Controller;
import mx.rpc.ResultEvent;
import mx.rpc.FaultEvent;
import org.roteroktober.zkmax.util.Callback;


class org.roteroktober.zkmax.util.Deferred {
                                                 
    public var type = "deferred";
    private var _localCallback:Callback;
    private var _localObject:Object;
    private var _remoteFunc:String; 
    private var _remoteArg:Object; 
    private var _remoteCallback:String; 
    private var _errback:String; 
    
    public function Deferred(rf:Object,rc:String,re:String,o:Object){
        if(typeof(rf) == "string") {
            _remoteFunc = String(rf);  
            _remoteArg = undefined;           
        } else {
            _remoteFunc = rf[0];
            _remoteArg = rf[1];
        }
        _remoteCallback = rc; 
        _errback = re;         
        if(!o) _localObject = Controller.getController();
        else _localObject = o;
    };        
    
    public function isDeferred():Boolean
    {
        return true;
    }
    
    public function addCallback(cb:Callback)
    {                     
        _localCallback = cb;
        if(_remoteArg)
            Controller.getController().getService()[_remoteFunc](_remoteArg).responder = new RelayResponder(this,"onEvent","onFault");                
        else 
            Controller.getController().getService()[_remoteFunc]().responder = new RelayResponder(this,"onEvent","onFault");                
    }

    public function onEvent(e:ResultEvent)
    {                         
        _localCallback.call(_localObject[_remoteCallback](e));
    }

    public function onFault(e:FaultEvent)
    {
        if(!_errback)
            Controller.getController().onError(e)
        else
            _localObject[_errback](e)                         
    }

};