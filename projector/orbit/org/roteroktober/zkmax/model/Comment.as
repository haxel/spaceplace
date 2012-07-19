//
//  org.roteroktober.zkmax.model.Comment
//
//  Created by Axel Heide on 2006-05-16.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//

import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.Controller;
import org.roteroktober.zkmax.model.IClickable;
import org.roteroktober.zkmax.util.Deferred;
import org.roteroktober.zkmax.model.Entry;

class org.roteroktober.zkmax.model.Comment implements IClickable
{

    public var id:String; 
    public var comment:String; 
    public var filename:String; 
    public var nid:Entry; 

    public function setPath(){
        filename = Controller.SERVER_URL + "/uploads/"+filename+".jpg";
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