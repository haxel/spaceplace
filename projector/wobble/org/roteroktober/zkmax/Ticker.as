//
//  Ticker
//
//  Created by Axel Heide on 2006-05-23.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Wobble;

class org.roteroktober.zkmax.Ticker {

    private var textfield:TextField;
    private var title:String;
    private var body:String;
    
    function Ticker(title:String,body:String){
        this.title = title;
        this.body = body;
    };
    
    function draw(mc:MovieClip)
    {
        mc._x = 0;
        mc.createTextField("tickertext",1,0,0,8000,30);
        this.textfield = mc["tickertext"];
        this.textfield.embedFonts = true;
        this.textfield._x = 1024;
        var fmt = new TextFormat();
        fmt.color = 0xFFFFFF;
        fmt.font = "HelveticaBlackCond";
        fmt.size = 20;
        this.textfield.setNewTextFormat(fmt);
        this.textfield.text = "                               " + title + ":      " + body;
        var scope = this;
        mc.onEnterFrame = function()
        {
            if(this._x > -this['tickertext'].textWidth-1024)
            {
                this._x-=3;
            } else {
                scope.done();
            }
        }
    }
    
    function done()
    {
        Wobble.getInstance().showNextTicker();
    }
};