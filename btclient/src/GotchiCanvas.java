import javax.microedition.lcdui.*;
import javax.microedition.media.MediaException;

public class GotchiCanvas extends Canvas implements ServerListener{

    private ControllerBluetooth client;                            
    private boolean connected = false;
    private boolean uploaded = false;
    private volatile String message;
    
    private Image image,gotchiImg,img_intro;
    private byte[] snapshot;

    private int x;
    private int y;

    public GotchiCanvas(byte[] raw) {   
        uploaded = false;
        snapshot = raw;
        image = Image.createImage(snapshot, 0, snapshot.length);
        message = "";
        addCommand(OrbitMIDlet.getApp().mSendImageCommand);
        try {
            // load an image from file system
            gotchiImg = Image.createImage("/gotchi.png");
            img_intro = Image.createImage("/intro_remote.png");
        } catch (Exception e) {}
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
        } else {        
            if(image != null) g.drawImage(image,width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);       
            g.drawImage(gotchiImg, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);
        }
    }

    public void startTransport() {
        client = new ControllerBluetooth();
        client.addListener(this);
    }  

	public void sendGotchi() {
        message = "You can now send your image to orbit. Click on the command 'send image to orbit";
        repaint();
	}

    public void stopTransport() {
        client.destroy();
    }  
    
    public void onMessageReceived(String s)
    {
        message = s;
        uploaded = true;
        repaint();      
    }

    public void onConnectionClosed(String s)
    {
    }

    public void onBluetoothInit(boolean ready)
    {
        if (!ready) OrbitMIDlet.getApp().bail("could not access bluetooth subsystem");
    }   

    public void onConnectionOpenSuccess()
    {      
        connected = true;
        if(snapshot != null && !uploaded) {
            // send with users offset
            client.send(snapshot,x-getWidth()/2,y-getHeight()/2);
        } else if(uploaded) {            
            message = "Your picture is already in orbit";
            repaint();
        } else {
            message = "picture is not available";
            repaint();
        }
    }    

    public void onConnectionOpenFailed(String s)
    {
        message = "could not send picture to server. Try again in a second";
        repaint();
    }

}
