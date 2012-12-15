import javax.jmdns.impl.constants.*;
import javax.jmdns.impl.*;
import javax.jmdns.impl.tasks.state.*;
import javax.jmdns.*;
import javax.jmdns.impl.tasks.*;
import javax.jmdns.test.*;
import javax.jmdns.impl.tasks.resolver.*;
import com.strangeberry.jmdns.tools.*;


String REMOTE_TYPE = "_myProject._tcp.local.";
String REMOTE_PROPERTY_ID = "DevName";
JmDNS jmdns = null;
ServiceInfo[] infos;
boolean listening = true;
boolean shouldQuit = false;

long interListeningScanMillis = 5000;
long lastListeningScanMillis = 0;


void setup() {
  size(100, 100);
  println("Opening JmDNS Listener...");
  try {
    jmdns = JmDNS.create();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
  println("Opened JmDNS Listener!");
  println("Listening: " + listening);
}



void keyPressed() {
  if (key == 'l') {
    listening = !listening;
    println("Listening: " + listening);
  }

  if (key == 'q') {    
    shouldQuit = true;
  }
}

void draw() {

  if ((listening) && ((millis() - lastListeningScanMillis) > interListeningScanMillis)) {
    lastListeningScanMillis = millis();
    infos = jmdns.list(REMOTE_TYPE);
    System.out.print("Scanning advertised services " + REMOTE_TYPE + ": ");
    if (infos.length == 0) {
      println("No Peers found.");
    } 
    else {   
      println();
      for (int i = 0; i < infos.length; i++) {
        println("Nice Name: " + infos[i].getNiceTextString());
        println("URLs: ");
        for (String url : infos[i].getURLs()){
          println("\t" + url);
        }
        println("port: " + infos[i].getPort());
        println("Server Name: " + infos[i].getServer());
        println("Protocol: " + infos[i].getProtocol());

/*  Not Working
        Enumeration<String> props = infos[i].getPropertyNames();
        println("Property Names: ");
        println("Props: " + props);
*/

        println("Name: " + infos[i].getName());
        println("Key: " + infos[i].getKey());
        println(REMOTE_PROPERTY_ID + ": " + infos[i].getPropertyString(REMOTE_PROPERTY_ID));

        println("IPv4 URLs: ");
        for (InetAddress url: infos[i].getInet4Addresses()) {
          println("\t" + url.toString());
        }

        if (infos[i].hasData()) {
          println ("Has Data");
    }
/*  Not Interesting
for (ServiceInfo.Fields c : ServiceInfo.Fields.values())
    System.out.println(c);
*/
    }
    }
  }


  if (shouldQuit) {
    println("Closing JmDNS Listener...");
    if (jmdns != null) try {
      jmdns.close();
    } 
    catch (IOException exception) {
      println("Error closing JmDNS Listener");
    }
    println("JmDNS Listener Closed!");
    System.exit(0);
  }
}

