
void setup() {
  // initialize serial communication at 9600 bps
  Serial.begin(9600);
  //check serial communication - acknowledgement routine
  Serial.println('a');  //sending a character to the PC
  char a = 'b';
  while ( a!='a' ){
    //wait for a precific character from the PC
    a = Serial.read(); 
   

  }

}

void loop() {
  // put your main code here, to run repeatedly:


}
