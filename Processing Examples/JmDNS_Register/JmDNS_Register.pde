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
String PROJECT_NAME = "MyGreatProject";
JmDNS jmdns = null;
ServiceInfo pairservice = null;
boolean advertising = false;
boolean shouldBeAdvertising = true;

boolean shouldQuit = false;
int id;
Random random;
long lastAdvertisementMillis = 0;
long advertisementIntervalMillis = 2000;


void keyPressed() {
  if (key == 'r') {
      shouldBeAdvertising = !shouldBeAdvertising;
  }

  if (key == 'q') {    
    shouldBeAdvertising = false;
    shouldQuit = true;
  }
}

void setup() {
  size(400, 100);

  println("Opening JmDNS...");
  try {
    jmdns = JmDNS.create();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  println("Opened JmDNS!");
  random = new Random();
  id = random.nextInt(100000);
  println("\nPress r to register Itunes Remote service "+ PROJECT_NAME + " " + id);
  println("Press q to quit");

}

void draw() {

  if (advertising) {
    background(0,255,0,50);
  } else {
    background(255,0,0,50);
  }
  if ((!advertising && shouldBeAdvertising) && (millis() - lastAdvertisementMillis) > advertisementIntervalMillis) {
    lastAdvertisementMillis = millis();
    final HashMap<String, String> values = new HashMap<String, String>();
    values.put(REMOTE_PROPERTY_ID, "MyGreatProject-" + id);
//    values.put("RemV", "10000");
//    values.put("DvTy", "iPod");
//    values.put("RemN", "Remote");
//    values.put("txtvers", "1");
    byte[] pair = new byte[8];
    random.nextBytes(pair);
    values.put("Pair", toHex(pair));

    byte[] name = new byte[20];
    random.nextBytes(name);
    println("Requesting pairing for " + toHex(name));
    pairservice = ServiceInfo.create(REMOTE_TYPE, toHex(name), 1025, 0, 0, values);

    try {
      jmdns.registerService(pairservice);
    } 
    catch (IOException e) {
      e.printStackTrace();
    }

    println("\nRegistered Service as " + pairservice);
    advertising = true;
  }

  if (advertising && !shouldBeAdvertising) {
    println("Closing JmDNS Registered Service...");
      try {
        jmdns.unregisterService(pairservice);
        jmdns.unregisterAllServices();
      }
      catch (NullPointerException e) {
      }
    println("JmDNS Registered Service Closed!");
    advertising = false;
  }
  
  if (shouldQuit && !advertising){
    println("Killing JmDNS...");
      try {
        jmdns.close();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
      catch (NullPointerException e) {
      }
    println("JmDNS Closed!");
    System.exit(0);
  }
}


char[] _nibbleToHex = { 
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};



String toHex(byte[] code) {
  StringBuilder result = new StringBuilder(2 * code.length);

  for (int i = 0; i < code.length; i++) {
    int b = code[i] & 0xFF;
    result.append(_nibbleToHex[b / 16]);
    result.append(_nibbleToHex[b % 16]);
  }

  return result.toString();
}

