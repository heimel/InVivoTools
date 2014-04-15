//sine wave + DC pulses

int waveform = 1; // 1:AC Stimulation        2:DC Stimulation
int AC = 3;       // 1:Complete sine wave    2:Anodal sine        3:Cathodal sine
int DC = 2;       // 1:Anodal DC             2:Cathodal DC

//Sine wave:
double elec_diameter = 3; //in mm  ~Set diameter~
double current_density = 0.057;    //in mA/mm^2  ~Set density~

const double pi = 3.14159;
double elec_surface = pi * sq(elec_diameter / 2);
double stimulation_current = current_density * elec_surface; //in mA  I = J*A = [mA/mm^2] * [mm]
double voltage_out = 1 * stimulation_current;  // depending on current gerenerator properties -> with output range at ISOLATOR: x10

double output = (( voltage_out * 4095) / 6.6); // normalization!    ((~~Maximum Voltage: 3.3Volts))

const int sample = 120;     //samples in sine[] table
const int zerolevel = 2043;
const int default_frequency = 1; // Hz

int oneHzSample = 1000000 / sample ; // sample for the 1Hz signal expressed in microseconds
int frequency = 0;  //in Hz

int sine[] = {
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

float f_sine[sample];
int signal_sine[sample];
int anodal_sine[sample];
int cathodal_sine[sample];
float timestep;    //(-5.5) fine for EEG frequencies (1~100Hz) ...  **Frequency doesn't go higher than 1.3kHz
int inPin = 2;

int trigger_armed = 0;
int trigger_tDCS = 0;

double stimulus_period = 5; // in s
double prestim_period = 5; // in s


void setup() {
  pinMode(inPin, INPUT_PULLUP);
  analogWriteResolution(12);    //analog output 12 bit (4096 levels)
  analogReadResolution(12);

  for (int i = 0; i < sample; i++) {
    f_sine[i] = (float) sine[i];   //convert int to float in order to change the amplitude
  }

  for (int i = 0; i < sample; i++) {
    f_sine[i] = ((f_sine[i] / 3.4) * voltage_out) + 2048 - (4096 / 3.4) * (voltage_out / 2); //gives the right amplitude --> volt
  }

  for (int i = 0; i < sample; i++) {
    signal_sine[i] = (int) f_sine[i];  //convert back to int
  }

  for (int i = 0; i < sample; i++) {
    if (signal_sine[i] > zerolevel) {
      anodal_sine[i] = signal_sine[i];
    }
    else {
      anodal_sine[i] = zerolevel;
    }
  }

  for (int i = 0; i < sample; i++) {
    if (signal_sine[i] < zerolevel) {
      cathodal_sine[i] = signal_sine[i];
    }
    else {
      cathodal_sine[i] = zerolevel;
    }
  }

  analogWrite(DAC1, zerolevel);

  // initialize serial communication at 9600 bps
  Serial.begin(9600);
  delay(1000);
  Serial.write( frequency );

}

void loop() {
  int gostate;

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




          int N = 0;
          int i = 0;
          int cycles = sample * stimulus_period * frequency;

          switch (AC) {
            case 1: // complete sine
              while (N < cycles) {
                analogWrite(DAC1, signal_sine[i]);
                i++;
                if (i == sample) {
                  i = 0;
                }
                timestep = oneHzSample / frequency - 5.5;
                delayMicroseconds(timestep);  //works fine up to ~180Hz
                N++;
              }
              break;
            case 2: //anodal sine
              while (N < cycles) {
                analogWrite(DAC1, anodal_sine[i]);
                i++;
                if (i == sample) {
                  i = 0;
                }
                timestep = oneHzSample / frequency - 5.5;
                delayMicroseconds(timestep);  //works fine up to ~180Hz
                N++;
              }
              break;
            case 3:  //cathodal sine
              while (N < cycles) {
                analogWrite(DAC1, cathodal_sine[i]);
                i++;
                if (i == sample) {
                  i = 0;
                }
                timestep = oneHzSample / frequency - 5.5;
                delayMicroseconds(timestep);  //works fine up to ~180Hz
                N++;
              }
              break;
          }  // switch(AC){}
          analogWrite(DAC1, zerolevel);  //2043 --> 0Volts output (correcting for the off-set)
        }
        Serial.write( frequency );
        delay(50);
      }
      break;
    case 2:  //DC Stimulation
      if (gostate & trigger_armed) {
        trigger_tDCS = 1;
        trigger_armed = 0;
      }
      if (!gostate & !trigger_armed) {
        trigger_armed = 1;
      }
      switch (DC) {
        case 1:  //anodal DC
          if (trigger_tDCS) {
            trigger_tDCS = 0;
            delay(prestim_period * 1000) ;  //Stimulation duration in milliseconds
            analogWrite(DAC1, output + zerolevel);  //(correcting for the off-set)
            delay(stimulus_period * 1000);
            analogWrite(DAC1, zerolevel);
          }
          break;
        case 2:  //cathodal DC
          double minus_output = -output;
          if (trigger_tDCS) {
            trigger_tDCS = 0;
            delay(prestim_period * 1000) ;  //Stimulation duration in milliseconds
            analogWrite(DAC1, minus_output + zerolevel);  //(correcting for the off-set)
            delay(stimulus_period * 1000);
            analogWrite(DAC1, zerolevel);
          }
          break;
      }
      analogWrite(DAC1, zerolevel);  //2043 --> 0Volts output (correcting for the off-set)
      Serial.write( frequency );
      delay(50);
      break;
  }    //switch(waveform){}
}


