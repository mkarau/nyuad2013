/*
  Blink
 Turns on an LED on for one second, then off for one second, repeatedly.
 
 This example code is in the public domain.
 */

// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
int ledPin = 13;

boolean ledOnState = true;
unsigned long lastLEDBlinkMillis = 0;
unsigned long LEDBlinkIntervalMillis = 1000000;

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(ledPin, OUTPUT);     
}

// the loop routine runs over and over again forever:
void loop() {
  // Check to see if it's time to blink the LED.
  // If not, do nothing.
  if ((unsigned long)(millis() - lastLEDBlinkMillis) > LEDBlinkIntervalMillis) {
    lastLEDBlinkMillis = millis();    // Mark the millis() at which we last blinked.
    ledOnState = !ledOnState;      // Toggle the state of the LED.
  }

  if (ledOnState) {
    digitalWrite(ledPin, HIGH);   // turn the LED on (HIGH is the voltage level)
  } 
  else {
    digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
  }
}

