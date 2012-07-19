import javax.microedition.lcdui.*;
import javax.microedition.media.control.*;
import javax.microedition.media.*;

public class CameraCanvas extends Canvas {
        
	private boolean active = false; 
    
    public CameraCanvas(VideoControl videoControl) {
              
        int width = getWidth();
        int height = getHeight();
        
        videoControl.initDisplayMode(VideoControl.USE_DIRECT_VIDEO, this);
        try {
            videoControl.setDisplayLocation(2, 2);
            videoControl.setDisplaySize(width - 4, height - 4);
        } catch (MediaException me) {}
        videoControl.setVisible(true);
                                      
	}
	
    public void paint(Graphics g) {
        int width = getWidth();
        int height = getHeight();

        g.setColor(0xCCCCCC);
		g.fillRect(0,0,getWidth(), getHeight());
    }
	
}
