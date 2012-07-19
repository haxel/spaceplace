//
//  Callback
//
//  Created by Axel Heide on 2006-01-19.
//  Copyright (c) 2006 Rokt. All rights reserved.
//

class org.roteroktober.zkmax.util.Callback {
                                                 
    private var _obj:Object;
    private var _func:String;
    private var _args:Array;
    
    public function Callback(fn:String,o:Object,args:Array){
        _obj = o;
        _func = fn;
        _args = args;
    };
    
    public function call()
    {        
        var args = new Array();
        if(_args != null) {
            args = arguments.concat(_args)
        } else 
            args = arguments
        trace(args)
        _obj[_func].apply(_obj,args);
    }

};