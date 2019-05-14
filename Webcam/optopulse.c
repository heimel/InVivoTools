/*
 * optopulse.c:
 *      blinks the first LED on raspberry pi
 * usage: optopulse DURATION=60 FREQUENCY=20 DUTYCYCLE=0.5 RAMPDURATION=0
 *   where DURATION is the total blink time in seconds
 *     and FREQUENCY is blinking frequency in Hz
 *     and RAMPDURATION is time (s) to linearly increase dutycycle from 1 ms to DUTYCYCLE
 *     and back down at the end. This is within the DURATION time, so time blinking
 *     at DUTYCYCLE is DURATION - 2*RAMPDURATION
 *
 * 200X, Gordon Henderson, projects@drogon.net
 * 2018-2019, Alexander Heimel
 *
 * to compile: gcc -o optopulse optopulse.c -lwiringPi -lm
 */
#define VERBOSE 1

#include <stdio.h> // for printf
#include <wiringPi.h>
#include <math.h> // for round
#include <unistd.h> // for usleep
#include <stdlib.h> // for atof
#include <time.h> // for time


int nonzerofrequency( float duration, float frequency, float dutycycle, float rampduration);
int zerofrequency( float duration );
void write_usage();


int main (int argc, char *argv[])
{
  float frequency = 20; // Hz
  float duration = 60; // s
  float dutycycle = 0.5; // fraction of cycle light is on
  float rampduration = 0; // s

  int ret;

  if (wiringPiSetup () == -1)
  {
    printf( "OPTOPULSE.C: wiringPiSetup returns -1. No pulse given.");
    return 1 ;
  }

  if (argc>1){
    if (argv[1][0]=='-'){
      write_usage();
      return 1;
    } else
      duration = atof( argv[1]);
  }

  if (argc>2)
    frequency = atof( argv[2]);

  if (argc>3)
    dutycycle = atof( argv[3]);

  if (argc>4)
    rampduration = atof( argv[4]);        


  printf ("OPTOPULSE.C: Requested blinking for %.2f s at %.1f Hz with %.1f dutycycle including ramps of %f .\n",
	duration,frequency,dutycycle,rampduration) ;

  pinMode (0, OUTPUT) ;         // aka BCM_GPIO pin 17

  if (frequency==0)
     ret = zerofrequency( duration );
  else
     ret = nonzerofrequency( duration, frequency, dutycycle, rampduration);

  digitalWrite (0, 0) ;       // Off (added for duration = 0)
  printf ("OPTOPULSE.C: Stopped blinking.\n") ;
  return 0 ;
}

int zerofrequency( float duration)
{
  printf ("OPTOPULSE.C: On for %.2f s. Not pulsing. Not ramping.\n",duration);
  
  digitalWrite (0, 1) ; // On
  usleep ( round(duration*1000000) ) ; 
}


int nonzerofrequency( float duration, float frequency, float dutycycle, float rampduration)
{
  float levelduration; // s, duration - 2*rampduration
  int writetime_us = 111; // time to write pin
  int min_onduration_us = 1000; // minimum time pulse on
  int i;
  int cycletime_us; // time of one pulse cycle (on+off) 1000000/frequency
  int onduration_us; // time pulse on
  int offduration_us; //  time pulse off
  int n_cycles_during_ramp; 
  int n_cycles_during_level;
  struct timespec starttime, curtime;

  // rounding all input parameters to integer number of cycles
  cycletime_us = round(1000000./frequency);
  frequency = 1000000./cycletime_us;
  n_cycles_during_ramp = round(rampduration * frequency);
  rampduration = n_cycles_during_ramp / frequency;
  levelduration = duration - 2*rampduration;
  n_cycles_during_level = round(levelduration * frequency);
  levelduration = n_cycles_during_level / frequency;
  duration = levelduration + 2*rampduration;

  printf ("OPTOPULSE.C: Start blinking for %.2f s at %.1f Hz with %.1f dutycycle including ramps of %f .\n",
	duration,frequency,dutycycle,rampduration) ;

  clock_gettime(CLOCK_MONOTONIC,&starttime);

  if (VERBOSE){
    printf("OPTOPULSE.C: Verbose mode on.\n");
  }

  // ramp up
  for (i=0;i<n_cycles_during_ramp;i++)
  {
     onduration_us = min_onduration_us + 
            round( (dutycycle * cycletime_us - min_onduration_us)/n_cycles_during_ramp) * i;
     offduration_us = cycletime_us - onduration_us;
     digitalWrite (0, 1) ; // On
     if (VERBOSE){
        clock_gettime(CLOCK_MONOTONIC,&curtime);
        printf("%f,1\n",(curtime.tv_sec-starttime.tv_sec) + 
                (curtime.tv_nsec - starttime.tv_nsec)*1e-9);
     }
     usleep (onduration_us - writetime_us) ; 
     if (offduration_us>writetime_us){
       digitalWrite (0, 0) ; // Off
       if (VERBOSE){
          clock_gettime(CLOCK_MONOTONIC,&curtime);
          printf("%f,0\n",(curtime.tv_sec-starttime.tv_sec) + 
                (curtime.tv_nsec - starttime.tv_nsec)*1e-9);
       }
       usleep (offduration_us - writetime_us) ;
     }
  }

  // level
  onduration_us = round(dutycycle * cycletime_us); 
  offduration_us = cycletime_us - onduration_us;

  for (i=0;i<n_cycles_during_level;i++) {
    digitalWrite (0, 1) ; // On
     if (VERBOSE){
        clock_gettime(CLOCK_MONOTONIC,&curtime);
        printf("%f,1\n",(curtime.tv_sec-starttime.tv_sec) + 
                (curtime.tv_nsec - starttime.tv_nsec)*1e-9);
     }
    usleep (onduration_us - writetime_us); 
    if (offduration_us>writetime_us){
      digitalWrite (0, 0) ; // Off
       if (VERBOSE){
          clock_gettime(CLOCK_MONOTONIC,&curtime);
          printf("%f,0\n",(curtime.tv_sec-starttime.tv_sec) + 
                (curtime.tv_nsec - starttime.tv_nsec)*1e-9);
       }
      usleep (offduration_us - writetime_us);
    }
  }

  // ramp down
  for (i=n_cycles_during_ramp-1;i>=0;i--)
  {
     onduration_us = min_onduration_us + 
            round( (dutycycle * cycletime_us - min_onduration_us)/n_cycles_during_ramp) * i;
     offduration_us = cycletime_us - onduration_us;
     digitalWrite (0, 1) ; // On
     if (VERBOSE){
        clock_gettime(CLOCK_MONOTONIC,&curtime);
        printf("%f,1\n",(curtime.tv_sec-starttime.tv_sec) + 
                (curtime.tv_nsec - starttime.tv_nsec)*1e-9);
     }
     usleep (onduration_us - writetime_us) ; 
     if (offduration_us>writetime_us){
       digitalWrite (0, 0) ; // Off
       if (VERBOSE){
          clock_gettime(CLOCK_MONOTONIC,&curtime);
          printf("%f,0\n",(curtime.tv_sec-starttime.tv_sec) + 
                (curtime.tv_nsec - starttime.tv_nsec)*1e-9);
       }
       usleep (offduration_us - writetime_us) ;
     }
  }

  clock_gettime(CLOCK_MONOTONIC,&curtime);
  printf("OPTOPULSE.C: Finished after %.3f s.\n",
       (curtime.tv_sec-starttime.tv_sec) + 
       (curtime.tv_nsec - starttime.tv_nsec)*1e-9);


  return 0;
}


void write_usage()
{
  printf("optopulse.c: blinks the first LED on raspberry pi\n"
  "usage: optopulse DURATION=60 FREQUENCY=20 DUTYCYCLE=0.5 RAMPDURATION=0\n"
  "   where DURATION is the total blink time in seconds\n" 
  "     and FREQUENCY is blinking frequency in Hz\n" 
  "     and RAMPDURATION is time (s) to linearly increase dutycycle from 1 ms to DUTYCYCLE\n"
  "     and back down at the end. This is within the DURATION time, so time blinking\n"
  "     at DUTYCYCLE is DURATION - 2*RAMPDURATION\n"
  " 200X, Gordon Henderson, projects@drogon.net\n"
  " 2018-2019, Alexander Heimel\n");
}
