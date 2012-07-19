//
//  org.roteroktober.Autopilot
//
//  Created by Axel Heide on 2006-05-20.
//  Copyright (c) 2006 Roteroktober. All rights reserved.
//
import org.roteroktober.zkmax.Canvas;
import org.roteroktober.zkmax.Controller;
import org.roteroktober.zkmax.Alert;

class org.roteroktober.zkmax.Autopilot {

    private var interval:Number;
    private var callwait:Number;
    private var active:Boolean = false;
    
    private static var READING:Number = 1;
    private static var BROWSING:Number = 2;

    private var state:Number;
    private var watchdog:Number;
    private var secondsbeforestart:Number = 60;
    private var steps:Number = 5;
    private var movesteps:Number;
    
    public function Autopilot()
    {
        movesteps = steps
    }

    // has to be called every secondsbeforestart or it will start
    public function idle()
    {
        trace("idle called")
        if(active) stop();
        clearInterval(watchdog)
        watchdog = setInterval(this,"start",secondsbeforestart*1000);
    }

    public function next()
    {
        switch(Canvas.getInstance().state) 
        {
            case Canvas.PERSON:
                if(state==READING)
                {
                    callwait = 2000
                } else {
                    callwait = 2000                    
                }
                state=READING
                if(movesteps==0){
                    hit()
                    movesteps = 10
                }else
                    move()
                break;
            case Canvas.TAGS:
                state=BROWSING
                callwait = 2000                    
                if(movesteps==0){
                    hit()
                    movesteps = 14
                }else
                    move()
                break;
            case Canvas.TAG:
                state=BROWSING
                callwait = 2000                    
                if(movesteps==0){
                    hit()
                    movesteps = 6
                }else{
                    move()
                }
                break;
        }
    }    
    
    public function start()
    {
        clearInterval(watchdog)
        trace("start called")
        active = true;
        callwait = 3000;
        interval = setInterval(this,"next",callwait);
        var alert:Alert = new Alert("AUTOPILOT ON");
    }
    
    public function stop()
    {
        clearInterval(interval);
        active = false;
        var alert:Alert = new Alert("AUTOPILOT OFF");
    }
    
    public function hit()
    {
        clearInterval(interval);
        interval = setInterval(this,"next",callwait);
        Controller.getController().handleDirection(Controller.CODES_BT[1]);        
    }
    
    public function move()
    {
        clearInterval(interval);
        interval = setInterval(this,"next",callwait);
        // get a random direction
        var direction = Controller.CODES_BT[Math.ceil(Math.random()*4)+1]    
        Controller.getController().handleDirection(direction);
        movesteps--
    }

};