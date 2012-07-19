
import javax.microedition.lcdui.*;
import javax.bluetooth.*;
import java.util.Calendar;
import javax.microedition.midlet.MIDlet;
import java.util.*;
import javax.microedition.media.*;
import javax.microedition.media.control.*;

public class OrbitMIDlet extends MIDlet implements CommandListener {
    
    private static OrbitMIDlet mAPP;
    
    private Display mDisplay = null;
    private Form mMainForm;
    
    public Command mExitCommand, mCameraCommand, mRemoteCommand,mSwitchHostCommand,mStartCommand;
    public Command mBackCommand, mCaptureCommand, mSendImageCommand, mGotchiCommand;
    
    private Player mPlayer;
    private VideoControl mVideoControl;

    private RemoteCanvas canvasR;
    private CameraCanvas canvasC;
    private GotchiCanvas canvasG;
    
    public static boolean DEBUG = false; 
    public static String IP = ""; 
    public static String BT_ID = "";
    public static String BT_ID_1 = "";
    public static String BT_ID_2 = "";
    
    public static boolean HAS_CAMERA = false;
    public static boolean HAS_BLUETOOTH = false;
    
    public int SNAP_HEIGHT = 0;                     
    public int SNAP_WIDTH = 0;                     
    
    private Video video;
        
    public OrbitMIDlet() {
        mExitCommand = new Command("exit", Command.EXIT, 1);
        mRemoteCommand = new Command("connect to orbit", Command.SCREEN, 2);
        mSwitchHostCommand = new Command("switch hosts", Command.SCREEN, 5);
        mCameraCommand = new Command("make a gotchi", Command.SCREEN, 3);
        //mGotchiCommand = new Command("finish your gotchi", Command.SCREEN, 2);
        mBackCommand = new Command("back", Command.BACK, 4);
        mStartCommand = new Command("start", Command.SCREEN, 1);
        mCaptureCommand = new Command("capture a gotchi", Command.SCREEN, 2);
        mSendImageCommand = new Command("send image to orbit", Command.SCREEN, 2);
        
        mMainForm = new Form("Orbit");
        mMainForm.addCommand(mExitCommand);
        
        IP = getAppProperty("Orbit-IP");
        DEBUG = getAppProperty("Orbit-Debug").equals("TRUE");
        BT_ID_1 = getAppProperty("Orbit-BluetoothID");
        BT_ID_2 = getAppProperty("Orbit-BluetoothID-2");
        BT_ID = BT_ID_1;
        
        mMainForm.append(new StringItem("Welcome to Orbit","If you connect, you can control the installation. Someone else might be blocking - so make a gotchi in the meantime.\n\n"));
        
        String supports = System.getProperty("video.snapshot.encodings");
        String btapi= System.getProperty("bluetooth.api.version");
        HAS_CAMERA = (supports != null && supports.length() > 0) ? true : false;
        HAS_BLUETOOTH =  (btapi != null && btapi.length() > 0) ? true : true;
        
        if(!HAS_BLUETOOTH) {
            mMainForm.append(new StringItem("Sorry!","Your Device does not support the necessary bluetooth functionality\n\n"));            
        } else {
            mMainForm.addCommand(mRemoteCommand);
            if(DEBUG) mMainForm.addCommand(mSwitchHostCommand);
            if(!HAS_CAMERA) {
                mMainForm.append(new StringItem("Checking your device...","You can control the installation with your device, but i can not access the camera. You can't make a gotchi\n\n"));                            
            } else {
                mMainForm.append(new StringItem("Checking your device...","Great! Your device can handle everything\n\n"));                            
                mMainForm.addCommand(mCameraCommand);
            }
        }
        mMainForm.append(new StringItem("Help","If your device supports it you can now remote control the installation or make a gotchi. Choose either connect to orbit or make a gotchi from the menu\n\n"));                            
        
        mMainForm.setCommandListener(this);   
        
        mAPP = this;
    }
    
    public static OrbitMIDlet getApp() {
        return mAPP;
    }
    
    public void startApp() {
        if( mDisplay == null ){
            initMIDlet();
        }
    }
    
    private void initMIDlet(){
        mDisplay = Display.getDisplay(this);
        SplashCanvas scanvas = new SplashCanvas();
        scanvas.addCommand(mStartCommand);
        scanvas.setCommandListener(this);
        mDisplay.setCurrent( scanvas );
    }
    
    public void showMain() {
        mDisplay.setCurrent(mMainForm);        
    }
    
    public void pauseApp() {}
    
    public void destroyApp(boolean unconditional) {}
    
    public void commandAction(Command c, Displayable s) {
        if (c.getCommandType() == Command.EXIT) {
            destroyApp(true);
            notifyDestroyed();
        }
        else if (c == mCameraCommand)
            showCamera();
        else if (c == mRemoteCommand)
            showRemote();
        else if (c == mSwitchHostCommand) {
            BT_ID = (BT_ID.equals(BT_ID_2)) ? BT_ID_1 : BT_ID_2;
            bail("set to " + BT_ID);
        } else if (c == mBackCommand && s == canvasR) {
            if(canvasR.connected) 
                canvasR.stopTransport();        
            else 
                showMain();    
        } else if (c == mBackCommand && s == canvasC) {
            canvasC.removeCommand(mBackCommand);
            showMain();
        } else if (c == mBackCommand && s == canvasG) {
            showMain();   
        } else if (c == mBackCommand || c == mStartCommand) {
            showMain();
        } else if (c == mCaptureCommand) {
            canvasC.addCommand(mBackCommand);
            video = new Video(this);            
            video.start();
        } else if (c == mSendImageCommand) {
            canvasG.addCommand(mBackCommand);
            canvasG.startTransport();
        }
    }
    
    public void bail(String s) {
        Form alert = new Form("Orbit Message");
        alert.append(new StringItem("Attention",s + "\n\n"));                            
        alert.addCommand(mBackCommand);
        alert.setCommandListener(this);      
        mDisplay.setCurrent(alert);
    }
    
    private void showCamera() {
        try {
            mPlayer = Manager.createPlayer("capture://video");
            mPlayer.realize();
            mVideoControl = (VideoControl)mPlayer.getControl("VideoControl");
            canvasC = new CameraCanvas(mVideoControl);
            canvasC.addCommand(mBackCommand);
            canvasC.addCommand(mCaptureCommand);
            canvasC.setCommandListener(this);
            mDisplay.setCurrent(canvasC);
            mPlayer.start();
        } 
        catch (MediaException me) {}
        catch (Exception ioe) {} 
                
    }
    
    class Video extends Thread {
        
        private final OrbitMIDlet midlet;
        
        public Video(OrbitMIDlet midlet) {
            this.midlet = midlet;
        }
        
        public void run() {
            captureVideo();
        }
        
        public void captureVideo() {
            try {
                byte[] raw = mVideoControl.getSnapshot("encoding=png&width=160&height=120");
                //Image image = Image.createImage(raw, 0, raw.length);
                mPlayer.close();
                mPlayer = null;
                mVideoControl = null;
                midlet.showGotchi(raw);
            } catch (MediaException me) { }
        }
    };    
           
        
    private void showRemote() {
        mDisplay = Display.getDisplay(this);
        canvasR = new RemoteCanvas();
        canvasR.addCommand(mBackCommand);
        canvasR.setCommandListener(this);
        mDisplay.setCurrent(canvasR);
    }
        
    public void showGotchi(byte[] imgData) {
        if(imgData == null)
        {
            bail("sorry image could not be captured");
        }
        canvasG = new GotchiCanvas(imgData);
        //canvasG.addCommand(mGotchiCommand);
        canvasG.setCommandListener(this);
        mDisplay.setCurrent(canvasG);
    }
    
    public void handleException(Exception e) {
        bail(e.toString());
        /*Alert a = new Alert("Exception", e.toString(), null, null);
        a.setTimeout(3000);
        mDisplay.setCurrent(a, mMainForm);*/
    }
    
    synchronized public static void log(String msg) {
        StringBuffer sb = new StringBuffer();
        Calendar cal = Calendar.getInstance();
        int hh = cal.get(Calendar.HOUR_OF_DAY);
        if(hh < 10 ) sb.append(0);
        sb.append(hh);
        sb.append(":");
        int mm = cal.get(Calendar.MINUTE);
        if(mm < 10 ) sb.append(0);
        sb.append(mm);
        sb.append(":");
        int ss = cal.get(Calendar.SECOND);
        if(ss < 10 ) sb.append(0);
        sb.append(ss);
        System.out.println(sb + ":" + msg);
    }

    public static String[] split(String original, String separator) {
        Vector nodes = new Vector();

        // Parse nodes into vector
        int index = original.indexOf(separator);
        while(index>=0) {
            nodes.addElement( original.substring(0, index) );
            original = original.substring(index+separator.length());
            index = original.indexOf(separator);
        }
        // Get the last node
        nodes.addElement( original );

        // Create splitted string array
        String[] result = new String[ nodes.size() ];
        if( nodes.size()>0 ) {
            for(int loop=0; loop<nodes.size(); loop++)
            result[loop] = (String)nodes.elementAt(loop);
        }
        return result;
    }
    
}
