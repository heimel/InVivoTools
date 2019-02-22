//sine wave + DC pulses

int waveform = 2; // 1:AC Stimulation        2:DC Stimulation
int AC = 1;       // 1:Complete sine wave    2:Anodal sine        3:Cathodal sine
int DC = 1;       // 1:Anodal DC             2:Cathodal DC

//Sine wave:
const double elec_diameter = 3; //in mm  ~Set diameter~
// before 2017-12-18
//const double current_density = 0.0105;    //in mA/mm^2  ~Set density~

// changed 2017-12-18, to 3 times less, (we will also use 10x stimulation now), so in total 3x times less
//const double current_density = 0.0035;    //in mA/mm^2  ~Set density~

// changed 2017-12-18, to 6 times less of orginal, (we will also use 10x stimulation now), so in total 3x times less
//const double current_density = 0.00175;    //in mA/mm^2  ~Set density~

// changed 2017-12-18, to 3 times less, (we will also use 10x stimulation now), so in total 3x times less
//const double current_density = 0.0035;    //in mA/mm^2  ~Set density~

// changed 2017-12-27, to 6 times less of orginal, (we will also use 10x stimulation now), so in total 3x times less
const double current_density = 0.00175;    //in mA/mm^2  ~Set density~


const double pi = 3.14159;
double elec_surface = pi * sq(elec_diameter / 2);
double stimulation_current = current_density * elec_surface; //in mA  I = J*A = [mA/mm^2] * [mm]
double voltage_out = 1 * stimulation_current;  // depending on current gerenerator properties -> with output range at ISOLATOR: x10 --> 1*stimulation_current // ISOLATOR: x1 --> 10*stimulation_current

int dcoutput = (3-2*DC)*(( voltage_out * 4095) / 6.6); // relative to zerolevel    ((~~Maximum Voltage: 3.3Volts))

const int sample = 120;     //samples in sine[] table
const int zerolevel = 2049;  // calibrated such no stimulation occurs
const int default_frequency = 1; // Hz

int oneHzSample = 1000000 / sample ; // sample for the 1Hz signal expressed in microseconds
int frequency = 0;  //in Hz
int n_steps = 60;

float sine[] = {
  0x7ff, 0x86a, 0x8d5, 0x93f, 0x9a9, 0xa11, 0xa78, 0xadd, 0xb40, 0xba1,
  0xbff, 0xc5a, 0xcb2, 0xd08, 0xd59, 0xda7, 0xdf1, 0xe36, 0xe77, 0xeb4,
  0xeec, 0xf1f, 0xf4d, 0xf77, 0xf9a, 0xfb9, 0xfd2, 0xfe5, 0xff3, 0xffc,
  0xfff, 0xffc, 0xff3, 0xfe5, 0xfd2, 0xfb9, 0xf9a, 0xf77, 0xf4d, 0xf1f,
  0xeec, 0xeb4, 0xe77, 0xe36, 0xdf1, 0xda7, 0xd59, 0xd08, 0xcb2, 0xc5a,
  0xbff, 0xba1, 0xb40, 0xadd, 0xa78, 0xa11, 0x9a9, 0x93f, 0x8d5, 0x86a,
  0x7ff, 0x794, 0x729, 0x6bf, 0x655, 0x5ed, 0x586, 0x521, 0x4be, 0x45d,
  0x3ff, 0x3a4, 0x34c, 0x2f6, 0x2a5, 0x257, 0x20d, 0x1c8, 0x187, 0x14a,
  0x112, 0xdf, 0xb1, 0x87, 0x64, 0x45, 0x2c, 0x19, 0xb, 0x2,
  0x0, 0x2, 0xb, 0x19, 0x2c, 0x45, 0x64, 0x87, 0xb1, 0xdf,
  0x112, 0x14a, 0x187, 0x1c8, 0x20d, 0x257, 0x2a5, 0x2f6, 0x34c, 0x3a4,
  0x3ff, 0x45d, 0x4be, 0x521, 0x586, 0x5ed, 0x655, 0x6bf, 0x729, 0x794
};

//float f_sine[sample];
float signal_sine[sample];
float anodal_sine[sample];
float cathodal_sine[sample];
float timestep;    //(-5.5) fine for EEG frequencies (1~100Hz) ...  **Frequency doesn't go higher than 1.3kHz
int inPin = 2;

int trigger_armed = 0;
int trigger_tDCS = 0;

double stimulus_period = 5; // in s
double prestim_period = 2; // in s


void setup() {
  pinMode(inPin, INPUT_PULLUP);
  analogWriteResolution(12);    //analog output 12 bit (4096 levels)
  analogReadResolution(12);

//  for (int i = 0; i < sample; i++) {
//    f_sine[i] = (float) sine[i];   //convert int to float in order to change the amplitude
//  }

  for (int i = 0; i < sample; i++) {
    sine[i] = ((sine[i] / 3.4) * voltage_out) + zerolevel - (4096 / 3.4) * (voltage_out / 2); //gives the right amplitude --> volt
  }

//  for (int i = 0; i < sample; i++) {
//    signal_sine[i] = (int) f_sine[i];  //convert back to int
//  }

  switch (AC) {
    case 1: // complete sine
      break;
    case 2: //anodal sine
      for (int i = 0; i < sample; i++) {
        if (signal_sine[i] < zerolevel) {
          signal_sine[i] = zerolevel;
        }
      }
      break;
    case 3: //cathodal sine
      for (int i = 0; i < sample; i++) {
        if (signal_sine[i] > zerolevel) {
          signal_sine[i] = zerolevel;
        }
      }
      break;
  }

  analogWrite(DAC1, zerolevel);

  // initialize serial communication at 9600 bps
  Serial.begin(9600);
  delay(1000);
  Serial.write( frequency );
}

void loop() {
  int gostate;
  int output;

  if (Serial.available() > 0) { //if there is data to read
    frequency = Serial.read();
    Serial.flush();
  }

  gostate = !digitalRead(inPin); // input is reversed
           
  switch (waveform) {
    case 1: //AC Stimulation
      if (frequency != 0) {
        if (gostate & trigger_armed) {
          trigger_tDCS = 1;
          trigger_armed = 0;
        }
        if (!gostate & !trigger_armed) {
          trigger_armed = 1;
        }

        if (trigger_tDCS) {
          trigger_tDCS = 0;
          delay(prestim_period * 1000) ;  //Stimulation duration in milliseconds

          // check frequency
          Serial.write( frequency );
          delay(5);
          if (Serial.available() > 0) { //if there is data to read
            frequency = Serial.read();
            if (frequency>128){
               frequency = default_frequency; 
            }
            Serial.flush();
          }

          int i = 0;
          int cycles = sample * stimulus_period * frequency;

          for(int N=0;N<cycles;N++) {
            analogWrite(DAC1, signal_sine[i]);
            i++;
            if (i == sample) {
              i = 0;
            }
            timestep = oneHzSample / frequency - 5.5;
            delayMicroseconds(timestep);  //works fine up to ~180Hz
          }
          analogWrite(DAC1, zerolevel);  //2043 --> 0Volts output (correcting for the off-set)
        }
        Serial.write( frequency );
        delay(50);
      }
      break; //AC stimulation
    case 2:  //DC Stimulation 

      if (gostate & trigger_armed) {
        trigger_tDCS = 1;
        trigger_armed = 0;
      }
      if (!gostate & !trigger_armed) {
        trigger_armed = 1;
      }
      if (trigger_tDCS) {
        trigger_tDCS = 0;
        delay(prestim_period * 1000) ;  //Stimulation duration in milliseconds    
        output = dcoutput;      
        double stepsize = double(output/n_steps);
        
        for(int i=0; i<n_steps; i++){    // Slow Slope
          analogWrite(DAC1, zerolevel + i*stepsize);
          delay(25);
        }           
        analogWrite(DAC1, zerolevel + output);  //(correcting for the off-set)
        delay(stimulus_period * 1000);
        for(int i=n_steps; i>0; i--){    // Slow Slope
          analogWrite(DAC1, zerolevel + i*stepsize);
          delay(25);
        }
      } 
      analogWrite(DAC1, zerolevel);  //2043 --> 0Volts output (correcting for the off-set)
      
      delay(50);
      break;
  } //switch(waveform){}
}

