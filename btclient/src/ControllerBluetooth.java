import javax.microedition.lcdui.*;
import javax.microedition.io.*;
import java.io.*;

public class ControllerBluetooth implements Runnable {
    
    private StreamConnection conn = null;
    private DataOutputStream out = null;
    private DataInputStream in = null;
    private boolean done = false;
    private ServerListener listener;
    public boolean connected = false;
    
    public void addListener(ServerListener l) {
        listener = l;
        new Thread(this).start();
    }
        
    public void run() {
        // we don't have the bluetooth stuff available yet
        boolean isBTReady = false;
       
        
        StringBuffer url = new StringBuffer("btspp://");
        url.append(OrbitMIDlet.BT_ID);
        url.append(":1;master=false;encrypt=false;authenticate=false");

        try {
            //OrbitMIDlet.log("try to access: " + url.toString());
            conn = (StreamConnection) Connector.open(url.toString());
            isBTReady = true;
        } catch (IOException e) {
            destroy();
            if(OrbitMIDlet.DEBUG)
                listener.onConnectionOpenFailed(e.getMessage() + " " + OrbitMIDlet.BT_ID);
            else 
                listener.onConnectionOpenFailed(" could not connect ");

            return;
        }
        
        listener.onBluetoothInit(isBTReady);
        
        try {
            
            in = conn.openDataInputStream();
            out = conn.openDataOutputStream();
            listener.onConnectionOpenSuccess();
            connected = true;
            while (!done) {

                byte status = in.readByte();
                String message = "";
                if(status == (byte)0x1)
                  message = "connected. use the cursor keys or the joystick to take control";
                else if(status == (byte)0x2)
                  message = "picture was uploaded";
                
                if( message!= "") listener.onMessageReceived(message);
            }
            
        } catch (Exception e) {
            listener.onConnectionClosed("you have been disconnected from the system");
        } finally {
            destroy();
        }
    }

    public void send(byte b) {        
        try {
            byte[] arr = new byte[2];
            arr[0] = ((byte) 0x03);
            arr[1] = b;
            out.write(arr);
            out.flush();
        } catch (IOException e){
            listener.onConnectionClosed("you have been disconnected from the system");
        }
    }

    public static byte[] intToByteArray(int value) {
        byte[] b = new byte[4];
        for (int i = 0; i < 4; i++) {
            int offset = (b.length - 1 - i) * 8;
            b[i] = (byte) ((value >>> offset) & 0xFF);
        }
        return b;
    }
        
    public void send(byte[] raw,int x,int y) {        
        try {            
            ByteArrayOutputStream boas =   new ByteArrayOutputStream();
            boas.write((byte) 0x04);
            boas.write(intToByteArray(x));
            boas.write(intToByteArray(y));
            boas.write(intToByteArray((int)raw.length));
            boas.write(raw);
            boas.close();
            out.write(boas.toByteArray());
            out.flush();
        } catch (IOException e){
            listener.onConnectionClosed("you have been disconnected from the system");
        }
    }

    public void destroy() {
        done = true;
        connected = false;
        try{out.close();} catch (Exception e) {};
        try{in.close();} catch (Exception e) {};
        try{conn.close();} catch (Exception e) {};
        //listener = null;
    }
}