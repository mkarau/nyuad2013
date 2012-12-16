import javax.jmdns.impl.constants.*;
import javax.jmdns.impl.*;
import javax.jmdns.impl.tasks.state.*;
import javax.jmdns.*;
import javax.jmdns.impl.tasks.*;
import javax.jmdns.test.*;
import javax.jmdns.impl.tasks.resolver.*;
import com.strangeberry.jmdns.tools.*;


BackgroundMDNSScanner mDNSscanner = new BackgroundMDNSScanner(this, "_myProject._tcp.local.");

boolean listening = true;
boolean shouldQuit = false;
boolean foundPeers = false;

long interListeningScanMillis = 5000;
long lastListeningScanMillis = 0;


void setup() {
  size(400, 100);
  mDNSscanner.start();
}



void keyPressed() {
  if (key == 'l') {
    listening = !listening;
    println("Listening: " + listening);
    if (listening) foundPeers = false;
  }
}

void draw() {
  if (listening && mDNSscanner.servicesAvailable()) {
    background(0, 255, 0, 50);
  } 
  else {
    background(255, 0, 0, 50);
  }
  text((int)(frameRate), width/2, height/2);
}

// Background Serial Port Scanner Thread Class:
// Send Data as "raw serial" or "OSC"
// Connect our output to someone else. (send request)
// Connect someone else's output to us (send request)
// Send heartbeat packets + response to understand if we are dumping packets

// Background Scanner thread class:

public class BackgroundMDNSScanner implements Runnable {
  Thread thread;
  JmDNS _jmdns = null;
  ServiceInfo[] _infos;
  String REMOTE_TYPE = "_myProject._tcp.local.";
  String REMOTE_PROPERTY_ID = "DevName";
  boolean _foundPeers = false;

  public BackgroundMDNSScanner(PApplet parent, String serviceType) {
    parent.registerDispose(this);
    REMOTE_TYPE = serviceType;
  }

  public boolean servicesAvailable() {
    return _foundPeers;
  }
  
  
  public ServiceInfo[] getServices() {
    return _infos;
  }

  public void start() {
    thread = new Thread(this);
    println("Opening JmDNS Listener...");
    try {
      _jmdns = JmDNS.create();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    println("Opened JmDNS Listener!");
    println("Listening: " + listening);
    thread.start();
  }

  public void run() {
    // do something threaded here
    while (true) {
      if ((listening)) {// && ((millis() - lastListeningScanMillis) > interListeningScanMillis)) {
        lastListeningScanMillis = millis();
        try {
          _infos = _jmdns.list(REMOTE_TYPE);
        } 
        catch (NullPointerException e) {
          e.printStackTrace();
        }
        System.out.print("Scanning advertised services " + REMOTE_TYPE + ": ");
        if (_infos.length == 0) {
          println("No Peers found.");
          _foundPeers = false;
        } 
        else {   
          _foundPeers = true;
          println();
          for (int i = 0; i < _infos.length; i++) {
            println("Server Name: " + _infos[i].getServer());
            println("IPv4 URLs: ");
            for (InetAddress url: _infos[i].getInet4Addresses()) {
              println("\t" + url.toString());
            }
            println("port: " + _infos[i].getPort());
            println("Unique Connection ID: " + _infos[i].getName());
            println(REMOTE_PROPERTY_ID + ": " + _infos[i].getPropertyString(REMOTE_PROPERTY_ID));
            //            println("Nice Name: " + _infos[i].getNiceTextString());
            //            println("URLs: ");
            //            for (String url : _infos[i].getURLs()) {
            //              println("\t" + url);
            //            }
            //            println("Protocol: " + _infos[i].getProtocol());
            //            println("Key: " + _infos[i].getKey());
            //            if (_infos[i].hasData()) {
            //              println ("Has Data");
            //            }
          }
        }
      }
      try {
        Thread.sleep(1000);
      }
      catch (InterruptedException exception) {
        println("Error sleeping");
        exception.printStackTrace();
      }
    }
  }

  public void stop() {
    thread = null;
  }

  // this will magically be called by the parent once the user hits stop
  // this functionality hasn't been tested heavily so if it doesn't work, file a bug
  public void dispose() {
    println("Disposing of background listener thread");
    println("Closing JmDNS Listener...");
    if (_jmdns != null) try {
      _jmdns.close();
    } 
    catch (IOException exception) {
      println("Error closing JmDNS Listener");
    }
    println("JmDNS Listener Closed!");
    stop();
  }
} 

