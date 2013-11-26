#include <unistd.h>
#include <asm/io.h>
#include "ParallelPort.h"

JNIEXPORT jint JNICALL Java_parport_ParallelPort_readOneByte
  (JNIEnv * algo, jclass otro, jint portStatus)
{
   int ret;
   
   if (ioperm(portStatus, 3, 1)){perror("ioperm error");}
   
   ret = inb(portStatus);   
  
   if (ioperm(portStatus, 3, 0)){perror("ioperm error");}

   return ret;

}

JNIEXPORT void JNICALL Java_parport_ParallelPort_writeOneByte
  (JNIEnv * algo, jclass otro, jint portData, jint oneByte)
{
   if (ioperm(portData, 3, 1)){perror("ioperm error");}

   outb(oneByte,portData);

   if (ioperm(portData, 3, 0)){perror("ioperm error");}
}



