import javax.microedition.lcdui.*;
import java.util.*;
  
public class RemoteCanvas extends Canvas implements ServerListener{
    
    private Image img_intro,img_fire,img_up, img_down, img_left, img_right;
    private volatile String message;
    private int action;
    
    private ControllerBluetooth client;                            
    public boolean connected = false;
    
    public RemoteCanvas() {  
        message = "press a key to connect";
        try{
            img_intro = Image.createImage("/intro_remote.png");
            img_up = Image.createImage("/up.png");
            img_fire = Image.createImage("/fire.png");
            img_down = Image.createImage("/down.png");
            img_left = Image.createImage("/left.png");
            img_right = Image.createImage("/right.png");                    
        } catch (Exception e) {
        }
    }
      
    public void paint(Graphics g) {
        int width = getWidth();
        int height = getHeight();
        g.setColor(0xCCCCCC);
        g.fillRect(0,0,width,height);
        g.setColor(0);
        g.drawImage(img_intro, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            

        if(message != "")
        {
            String[] chunks = OrbitMIDlet.split(message," ");
            g.setColor (0);
            Font font = Font.getFont(Font.FACE_SYSTEM,Font.STYLE_PLAIN,Font.SIZE_SMALL);
            g.setFont(font);
            int twidth = 0;
            int theight = 0;
            for(int n=0;n<chunks.length;n++) {
                if(twidth > (width/2)) {
                    twidth = 0;
                    theight += font.getHeight() + 2;
                }
                g.drawString (chunks[n], twidth + 10, theight + 10, Graphics.LEFT | Graphics.TOP);
                twidth += font.stringWidth(chunks[n]) + font.stringWidth(" ");
            }
        }
        
        if(client == null || !client.connected) return;
        switch(action) {                
            case UP:
                g.drawImage(img_up, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            
            break;
            case DOWN:
                g.drawImage(img_down, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            
            break;
            case LEFT:
                g.drawImage(img_left, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            
            break;
            case RIGHT:
                g.drawImage(img_right, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            
            break;                                
            case FIRE:
                g.drawImage(img_fire, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            
            break;
        }
    }


    public void startTransport() {
        client = new ControllerBluetooth();
        client.addListener(this);
    }  

    public void stopTransport() {
        connected = false;
        client.destroy();
    }  
    
    public void onConnectionOpenSuccess()
    {
        connected = true;
        repaint();
    }
    

    public void onMessageReceived(String s)
    {
        message = s;
        repaint();      
    }

    public void onConnectionClosed(String s)
    {
        //OrbitMIDlet.getApp().bail("you have been disconnected - either you lost connection or someone else is connected");        
        message = "you have been disconnected - either you lost connection or someone else is connected";
        repaint();
    }

    public void onBluetoothInit(boolean ready)
    {
        if (!ready) OrbitMIDlet.getApp().bail("could not access bluetooth subsystem");
    }   
        
    public void onConnectionOpenFailed(String s)
    {
        // OrbitMIDlet.getApp().bail("could not access server. Try again in a few seconds.");   
        // check after 10s     
        connected = false;
        message = "try again in a few seconds";
        repaint();      
    }
    
    public void keyPressed(int keyCode) {
        if(!connected) {
            startTransport();
            return;
        };

        action = getGameAction(keyCode);
        message = "";
        switch(action)
        {
            case FIRE:
                client.send((byte) 0x01);
                break;
            case UP:
                client.send((byte) 0x02); 
                repaint();      
                break;
            case LEFT:
                client.send((byte) 0x03);       
                repaint();      
                break;
            case DOWN:
                client.send((byte) 0x04);       
                repaint();      
                break;
            case RIGHT:
                client.send((byte) 0x05);       
                repaint();      
                break;
        }
    }
    
    
}
