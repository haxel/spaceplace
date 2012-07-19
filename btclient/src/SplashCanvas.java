import javax.microedition.lcdui.*;

public class SplashCanvas extends Canvas{

    private Image welcome;
    
    public SplashCanvas() {  
        try{
            welcome = Image.createImage("/welcome.png");
        } catch (Exception e) {}
    }
    
    public void paint(Graphics g) {
        int width = getWidth();
        int height = getHeight();
        g.setColor(0xCCCCCC);
        g.fillRect(0,0,width,height);
        g.setColor(0);
        g.drawImage(welcome, width/2,height/2,Graphics.HCENTER | Graphics.VCENTER);                            
    }           
    
    public void keyPressed(int keyCode) {
        OrbitMIDlet.getApp().showMain();
    }
         
}
