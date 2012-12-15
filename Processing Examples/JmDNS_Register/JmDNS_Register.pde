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
ServiceInfo pairservice = null;
boolean advertising = false;
boolean shouldBeAdvertising = false;
int id;
Random random;

void keyPressed() {
  if (key == 'r') {
    if (!advertising) {
      shouldBeAdvertising = true;
    }
  }

  if (key == 'q') {    
    advertising = true;
    shouldBeAdvertising = false;
  }
}

void setup() {
  size(100, 100);

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
  println("\nPress r to register Itunes Remote service 'Android-'" + id);
  println("Press q to quit");

}

void draw() {


  if ((!advertising) && (shouldBeAdvertising)) {
    final HashMap<String, String> values = new HashMap<String, String>();
    values.put("DvNm", "Android-" + id);
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


  if ((advertising) && (!shouldBeAdvertising)) {
    advertising = false;
    println("Closing JmDNS...");
      try {
        jmdns.unregisterService(pairservice);
        jmdns.unregisterAllServices();
        jmdns.close();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
      catch (NullPointerException e) {
      }
    println("Done!");
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

