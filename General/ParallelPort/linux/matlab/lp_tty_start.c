/*============= Give a user program IO access : lp_tty_start.c =============

  PURPOSE - show use of ioperm and exec to give a non-root program
            direct IO access to just lp0/1/2 and ttyS0/1/2/3.
            Priority is also adjusted.
	    
    USAGE - ./ioperm_start ./target_program_name  param1 param2 ...  

     NOTE - ioperm allows access to a limited range of IO between
            0 and 0x3FF and no access to interrupt disable/enable.
	  - the setgid, setuid removes root privileges.  
          - setpriority adjusts process scheduling priority.
	  - the command line minus the first parameter (the target
	    program name) is sent to the target program. 
*/
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/io.h>
#include <sys/resource.h>

#define lp0   0x378       /* lp (LPT) base addresses. */
#define lp1   0x278
#define lp2   0x3BC
#define lp_length   3

#define ttyS0 0x3F8       /* ttyS (COM) port base addresses. */
#define ttyS1 0x2F8
#define ttyS2 0x3E8
#define ttyS3 0x2E8
#define ttyS_length 8

int main(int argc, char *argv[])
{ /*--- abort if no parameters.*/
    if ( argc < 2)
      {  fprintf(stderr,"   No target program name : aborting.\n") ;
         exit(-1) ;
      }
  
  /*--- set process priority, 0= normal, -20 highest, +20 lowest.*/
    setpriority( PRIO_PROCESS, 0, 0 ) ;

  /*--- Get access to the ports and remove root privileges.*/  
    if (ioperm(lp0, lp_length, 1)) 
      perror("Failed ioperm lp0 on") ; 
    if (ioperm(lp1, lp_length, 1)) 
      perror("Failed ioperm lp1 on") ; 
    if (ioperm(lp2, lp_length, 1)) 
      perror("Failed ioperm lp2 on") ; 
      
    if (ioperm(ttyS0, ttyS_length, 1)) 
      perror("Failed ioperm ttyS0 on") ; 
    if (ioperm(ttyS1, ttyS_length, 1)) 
      perror("Failed ioperm ttyS1 on") ; 
    if (ioperm(ttyS2, ttyS_length, 1)) 
      perror("Failed ioperm ttyS2 on") ; 
    if (ioperm(ttyS3, ttyS_length, 1)) 
      perror("Failed ioperm ttyS3 on") ; 
      
    setgid( getgid() ) ;
    setuid( getuid() ) ;  
  
  /*--- do the exec to the target program, 
        use argv array from parameter 1 onward.*/
    execvp(argv[1], &argv[1]) ;
  /*    if get here exec must have failed.*/  
    perror("   execv failed") ;
    fprintf(stderr, "   Target program was %s.\n", argv[1]) ;
    exit( -1) ;
}
 
