/* Receive Serial Data from Mindflex and send it out through the 
 JY-MCU Arduino Bluetooth Wireless Serial Port Module.
 
 */

#include <SoftwareSerial.h>
#include <Brain.h> //need to include Brain.h in your Arduino libraries directory


//creates Virtual Serial for Mindflex
SoftwareSerial bluetoothSerial(2, 3);
Brain brain(Serial);
String brainRead;

void setup() {
  Serial.begin(9600);
  bluetoothSerial.begin(9600);
}

void loop() {
  if (brain.update()) {
    brainRead = brain.readCSV();
    Serial.println(brainRead);
    bluetoothSerial.write(brainRead+"$"); //'$' is used as an encryption so that the android application knows where to split the incoming packets
  }
}

