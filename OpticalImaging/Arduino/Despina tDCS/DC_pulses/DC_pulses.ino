//DC pulses

double elec_diameter = 2.4; //in mm  ~Set diameter~
  const int zerolevel = 2043;

const double pi = 3.14159;
double elec_surface = pi*sq(elec_diameter/2);
double stimulation_current = 0.057*elec_surface; //in mA  I = J*A = [mA/mm^2] * [mm]
double voltage_out = 1*stimulation_current;    // depending on current gerenerator properties -> with output range at ISOLATOR: x10

double output = (( voltage_out * 4095)/6.6);  // normalization!    ((~~Maximum Voltage: 3.3Volts))

int inPin = 2;

int trigger_armed = 0;
int trigger_tDCS = 0;

double stimulus_period = 5; // in s
double prestim_period = 5; // in s


void setup() {
  analogWriteResolution(12);    //12 bit (4096 levels)
  analogReadResolution(12);
  pinMode(inPin, INPUT_PULLUP);
  
  analogWrite(DAC1, zerolevel);  

}

void loop() {
  int gostate = !digitalRead( inPin); // input is reversed

  if (gostate & trigger_armed){
    trigger_tDCS = 1;
    trigger_armed = 0;
  } 
  if (!gostate & !trigger_armed) {
    trigger_armed = 1;
  }

  if (trigger_tDCS){
    trigger_tDCS = 0;    
     delay(prestim_period*1000) ;    //Stimulation duration in milliseconds 
     analogWrite(DAC1, output+zerolevel);    //(correcting for the off-set)
     delay(stimulus_period*1000);
     analogWrite(DAC1, zerolevel); 
   } 
  }
