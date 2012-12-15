import javax.jmdns.impl.constants.*;
import javax.jmdns.impl.*;
import javax.jmdns.impl.tasks.state.*;
import javax.jmdns.*;
import javax.jmdns.impl.tasks.*;
import javax.jmdns.test.*;
import javax.jmdns.impl.tasks.resolver.*;
import com.strangeberry.jmdns.tools.*;


String REMOTE_TYPE = "_myProject._tcp.local.";
JmDNS jmdns = null;
ServiceInfo[] infos;
boolean listening = true;
boolean shouldQuit = false;


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

  if (listening) {

  infos = jmdns.list(REMOTE_TYPE);
      
      System.out.println("List " + REMOTE_TYPE);
      for (int i = 0; i < infos.length; i++) {
        System.out.println(infos[i]);
      }
      System.out.println();

      try {
        Thread.sleep(5000);
      } 
      catch (InterruptedException e) {

      }
  }
  
  
  if (shouldQuit) {
      println("Closing JmDNS Listener...");

    if (jmdns != null) try {
      jmdns.close();
    } 
    catch (IOException exception) {
      //
    }
    println("JmDNS Listener Closed!");
    System.exit(0);

  }
}

