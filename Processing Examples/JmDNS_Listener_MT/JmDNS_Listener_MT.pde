import javax.jmdns.impl.constants.*;
import javax.jmdns.impl.*;
import javax.jmdns.impl.tasks.state.*;
import javax.jmdns.*;
import javax.jmdns.impl.tasks.*;
import javax.jmdns.test.*;
import javax.jmdns.impl.tasks.resolver.*;
import com.strangeberry.jmdns.tools.*;

import processing.serial.*;

BackgroundMDNSScanner mDNSscanner = new BackgroundMDNSScanner(this, "_myProject._tcp.local.");

BackgroundSerialScanner serialScanner = new BackgroundSerialScanner(this);

boolean listening = true;
boolean shouldQuit = false;
boolean foundPeers = false;

Serial myPort;
int lf = 10;

long interListeningScanMillis = 5000;
long lastListeningScanMillis = 0;


void setup() {
  size(800, 200);


  myPort = new Serial(this, Serial.list()[0], 57600); 
  myPort.bufferUntil(lf);
  mDNSscanner.start();
  serialScanner.start();
}



void keyPressed() {
  if (key == 'L') {
    serialScanner.toggleListening();
    println("Serial Listening: " + serialScanner.getListeningState());
  }
  if (key == 'l') {
    mDNSscanner.toggleListening();
    println("mDNS Listening: " + mDNSscanner.getListeningState());
  }
}

void draw() {
  if (listening && mDNSscanner.servicesAvailable()) {
    background(0, 107, 0);
  } 
  else {
    background(107, 0, 0);
  }
  fill(255, 255, 255);
  text((int)(frameRate), width-30, 15);

  // Show Serial Ports
  int startY = 30;
  fill(255, 255, 255);

  text("Ports:", 10, startY);
  startY += 15;
  String status = "";
  for (int i=0; i< serialScanner.availablePorts().length; i++) {
    if (serialScanner.portUsable(i)) {
      fill(14, 255, 14);
      status = "Usable: ";
    } 
    else {
      fill(130, 130, 130);
      status = "NOT Usable: ";
    }
    text(status + serialScanner.availablePorts()[i], 10, startY);  
    startY+=15;
  }


  // Show mDNS Servers
  int startX = width - 460;
  startY = 30;
  fill(255, 255, 255);
  text("Services:", startX, startY);
  startY += 15;
  if (mDNSscanner.getServices() != null) {
    for (int i=0; i< mDNSscanner.getServices().length; i++) {
      fill(14, 255, 14);
      text(mDNSscanner.getServices()[i].getServer() + ":" + mDNSscanner.getServices()[i].getPort() + "("+ mDNSscanner.getServices()[i].getPropertyString("PortName") +")", startX, startY);  
      startY+=15;
    }
  }
}











// Background Serial Port Scanner Thread Class:
// Send Data as "raw serial" or "OSC"
// Connect our output to someone else. (send request: Please receive)
// Connect someone else's output to us (send request: Please send)
// Send heartbeat packets + response to understand if we are dumping packets
// Send data to "cosm sink"
// Query a port number on a server to get the serial port name.
// Each serial port on a computer has a separate port number.

// Hot-plugging serial ports.  (by config, have it always hope to establish
// connections to a certain few port names.

// Set desired routes.
//   e.g.  send from Port-Blah@localhost to Port-bleh@remoteHostName, Port-blix@remoterHost
//   e.g.  post from Port-Blah@localhost to cosm sink with ID
//   e.g.  receive from Port-bleh@remoteHostName to Port-Blah@localhost
//   e.g.  receive from cosm source with ID to Port-Blah@localhost 
//   e.g.  receive from cosm source with ID to Port-Blah@remoteHost
//   e.g.  received from ALL@remoteHost to port@localhost
//   e.g.  send from ALL@localhost to port@Remotehost

// enable password on connection so only we can affect our project.



public class BackgroundSerialScanner implements Runnable {
  Thread thread;
  Serial testPort = null;
  String[] _availablePorts;
  boolean[] _portUsability;
  String[] _usablePorts;
  boolean _foundPorts = false;
  boolean _listening = true;
  PApplet _parent = null;
  int _numberOfUsablePorts = 0;

  public BackgroundSerialScanner(PApplet parent) {
    parent.registerDispose(this);
    _parent = parent;
  }


  public boolean portUsable (int i) {
    if (i < _portUsability.length) {
      return _portUsability[i];
    } 
    else {
      return false;
    }
  }

  public void toggleListening() {
    if (_listening) {
      stopListening();
    } 
    else {
      startListening();
    }
  }

  public void startListening() {
    _listening = true;
  }

  public boolean getListeningState() {
    return _listening;
  }

  public void stopListening() {
    _listening = false;
    for (int i=0; i<_portUsability.length; i++) {
      _portUsability[i] = false;
    }
  }

  public boolean portsAvailable() {
    return _foundPorts;
  }


  public String[] availablePorts() {
    return _availablePorts;
  }

  public String[] usablePorts() {
    return _usablePorts;
  }

  public void start() {
    thread = new Thread(this);
    println("Opening Serial Port Listener...");
    println("Listening: " + _listening);
    thread.start();
  }

  public void run() {
    int _portNumber = 0;
    int _lastNumberOfPortsFound = 0;
    while (true) {

      if (_listening) {
        _availablePorts = Serial.list();
        if (_availablePorts.length != _lastNumberOfPortsFound) {
          _portUsability = new boolean[_availablePorts.length];
          _lastNumberOfPortsFound = _availablePorts.length;
        }

        println("Ports found: " + _availablePorts.length);
        //        for (String port : _availablePorts) {
        //          println(port);
        //        }        
        _portNumber = 0;
        for (String port : _availablePorts) {
          if (_listening) {
            try {
              testPort = new Serial(_parent, port, 57600);
              println("Successfully opened port" + port);
              if (_listening) {
                _portUsability[_portNumber] = true;
              }
            } 
            catch (NullPointerException e) {
              println("Port disappeared: " + port);
              e.printStackTrace();
              _portUsability[_portNumber] = false;
            }
            catch (RuntimeException e) {
              _portUsability[_portNumber] = false;
              println("Port in use: " + port);
            }
            try {
              Thread.sleep(100);
            }
            catch (InterruptedException exception) {
              println("Interrupted sleeping");
              exception.printStackTrace();
            }

            if (testPort != null) {
              try {
                testPort.clear();
                testPort.stop();
                println("Successfully closed port" + port);
              }    
              catch (NullPointerException exception) {
                println("Error closing serial Listener");
              }
            }
            try {
              Thread.sleep(500);
            }
            catch (InterruptedException exception) {
              println("Interrupted sleeping");
              exception.printStackTrace();
            }
            _portNumber ++;
          }
        }
      }

      try {
        Thread.sleep(500);
      }
      catch (InterruptedException exception) {
        println("Interrupted sleeping");
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
    println("Disposing of serial listener thread");
    println("Closing serial Listener...");
    stopListening();
    if (testPort != null) try {
      testPort.clear();
      testPort.stop();
    } 
    catch (NullPointerException exception) {
      println("Error closing serial Listener");
    }
    println("serial Listener Closed!");
    stop();
  }
} 



void serialEvent(Serial p) { 
  String inString = "";
  try {
    inString = p.readString();
  } 
  catch (Exception e) {
  }
  if (p == myPort) {
    println("Data Received from my Arduino");
    println(inString);
  }
} 




// Background Scanner thread class:

public class BackgroundMDNSScanner implements Runnable {
  Thread thread;
  JmDNS _jmdns = null;
  ServiceInfo[] _infos;
  String REMOTE_TYPE = "_myProject._tcp.local.";
  String REMOTE_PROPERTY_ID = "DevName";
  boolean _foundPeers = false;
  boolean _listening = true;

  public BackgroundMDNSScanner(PApplet parent, String serviceType) {
    parent.registerDispose(this);
    REMOTE_TYPE = serviceType;
  }

  public boolean servicesAvailable() {
    return _foundPeers;
  }

  public void toggleListening() {
    if (_listening) {
      stopListening();
    } 
    else {
      startListening();
    }
  }

  public void startListening() {
    _listening = true;
  }

  public boolean getListeningState() {
    return _listening;
  }

  public void stopListening() {
    _listening = false;
    _foundPeers = false;
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
    while (true) {
      if ((_listening)) {
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
        Thread.sleep(1500);
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
    stopListening();
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

