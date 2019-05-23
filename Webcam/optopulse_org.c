/*
 * optopulse.c:
 *      blinks the first LED on raspberry pi
 * usage: optopulse DURATION=60 FREQUENCY=20
 *   where DURATION is the total blink time in seconds
 *     and FREQUENCY is blinking frequency in Hz
 *
 * Adapted from Gordon Henderson, projects@drogon.net
 * by Alexander Heimel, 2018
 *
 * to compile: gcc -o optopulse optopulse.c -lwiringPi -lm
 */

#include <stdio.h> // for printf
#include <wiringPi.h>
#include <math.h> // for round
#include <unistd.h> // for usleep
#include <stdlib.h> // for atof

int main (int argc, char *argv[])
{
  int i;
  float frequency = 20; // Hz
  int writetime = 111; // us, time to write pin
  float duration = 60; // s


  if (argc>2)
    frequency = atof( argv[2]);

  int halfpulse = round(500000./frequency); //us


  if (argc>1)
    duration = atof( argv[1]);

  printf ("OPTOPULSE.C: Start blinking for %.2f s at %.1f Hz.\n",duration,frequency) ;

  if (wiringPiSetup () == -1)
    return 1 ;

  pinMode (0, OUTPUT) ;         // aka BCM_GPIO pin 17

  for (i=0;i<round(frequency*duration);i++)
  {
    digitalWrite (0, 1) ;       // On
    usleep (halfpulse-writetime) ;         // us
    digitalWrite (0, 0) ;       // Off
    usleep (halfpulse-writetime) ;         // us
  }

  digitalWrite (0, 0) ;       // Off (added for duration = 0)
  printf ("OPTOSPULSE.C: Stopped blinking.\n") ;

  return 0 ;
}

