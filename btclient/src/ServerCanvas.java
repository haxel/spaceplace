import javax.microedition.lcdui.*;

public class ServerCanvas extends Canvas implements ServerListener{

        protected ControllerBluetooth client;                            
        protected boolean connected = false;
        
        public void paint(Graphics g) {}           
        public void onMessageReceived(String s){}
        public void onBluetoothInit(boolean ready){}

        public void onConnectionOpenSuccess()
        {
            connected = true;
        }

        public void onConnectionOpenFailed(String s){}
        public void onConnectionClosed(String s){}

        public void startTransport() {
            client = new ControllerBluetooth();
            client.addListener(this);
        }  

        public void stopTransport() {
            client.destroy();
        }  
        
        public void start()  {} 
  
        public void capture()  {} 
         
}
