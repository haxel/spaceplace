

public interface ServerListener {

    public void onMessageReceived(String s);
    public void onBluetoothInit(boolean ready);
    public void onConnectionOpenSuccess();
    public void onConnectionOpenFailed(String s);
    public void onConnectionClosed(String s);
}