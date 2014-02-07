
/*
  DigitalReadSerial
 Reads a digital input on pin 2, prints the result to the serial monitor 
 
 This example code is in the publi
 c domain.
 */

void setup() {
  
  
  Serial.begin(9600);
  
  pinMode(0, INPUT);
  digitalWrite(0, HIGH);
  pinMode(8, INPUT);
  digitalWrite(8, HIGH);
  pinMode(2, INPUT);
  digitalWrite(2, HIGH);
  pinMode(3, INPUT);
  digitalWrite(3, HIGH);
  pinMode(4, INPUT);
  digitalWrite(4, HIGH);
  pinMode(5, INPUT);  
  digitalWrite(5, HIGH);
  pinMode(6, INPUT);
  digitalWrite(6, HIGH);
  pinMode(7, INPUT);
  digitalWrite(7, HIGH);
  
}



void loop() {
  int sensorValue = (1-digitalRead(6));
  sensorValue = sensorValue +   2 * (1-digitalRead(5));
  sensorValue = sensorValue +   4 * (1-digitalRead(4));
  sensorValue = sensorValue +   8 * (1-digitalRead(3));
  sensorValue = sensorValue +  16 * (1-digitalRead(2));
  sensorValue = sensorValue +  32 * (1-digitalRead(0));
  sensorValue = sensorValue +  64 * (1-digitalRead(8));
  sensorValue = sensorValue + 128 * (1-digitalRead(7));
  Serial.write(sensorValue);
}









