/***********************************************/
/* Matthew Vanderzee's code butchered by JI, Aug 97                               */
/* Please pardon the style -- I (JI) started coding in C in 1978 with 132 columns */
/************************************************/
/* This code is Q&D;  use as a template AYOR.   */
/* You may want to compile with the -ansi flag. */
/************************************************/

#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */

int main(void)	{
	char str[64];
	int n,dev;
	char c;

	printf("Begin:  Type q to end.\n");
	while(((c=getc(stdin)) != 'q') && (c != 'Q'))	{
		switch (c)	{
			case 'c':	GetPosition();
					break;
			case 's':	GetStats();
					break;
			case 'm':	Move();
					break;
			case 'v':	SetVelocity();
					break;
			case 'o':	SetOrigin();
					break;
			case 'n':	vfdRefresh();
					break;
			case  03:
			case  04:	Reminder();
					break;
			default:	break;
		}
	}  	
	return 1;
}

int Move(void)	{
	union CoordString {
		long	xyz;
		char	ByteString[4];
	} x, y, z;
	int num;
	char TestMove[]={ 'm', 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0 };
	char term[]="/dev/ttyd2";
	int SerialPort;

	SerialPort=open_port(term);
	if (!SerialPort) return 0;

	write(SerialPort,TestMove,13);
	write(SerialPort,"\r",1);
	sleep(1);

	close(SerialPort);
	return 0;
}

int GetPosition(void)	{
	char ReturnString[64];
	int num;
	char term[]="/dev/ttyd2";
	int SerialPort;

	SerialPort=open_port(term);
	if (!SerialPort) return 0;

	write(SerialPort,"c",1);
	write(SerialPort,"\r",1);
	sleep(1);

	num=read(SerialPort,ReturnString,13);
	if	(num<13) printf("Read Failed!  %s %d\n",(num<0 ? "Error Number:" : "Bytes Read:"),num);
	else if (ReturnString[12]==0xD) printf("Read Worked!\n");
	else 	printf("Read Failed!  Last byte not terminator!\n");
	printf("Bytes Read:\n");
	printbytes(ReturnString,num);

	close(SerialPort);
	return 0;
}
int GetStats(void)	{
	return 0;
}

int SetVelocity(void)	{
	return 0;
}

int SetOrigin(void)	{
	char term[]="/dev/ttyd2";
	int SerialPort;
	char c=13;

	SerialPort=open_port(term);
	if (!SerialPort) return 0;
	write(SerialPort,"o",1);
	write(SerialPort,&c,1);
	close(SerialPort);
	return 0;
}

int vfdRefresh(void)	{
	return 0;
}

int Reminder(void)	{
	return 0;
}

int printbytes(char *str,int numchars)	{
	int i;
	for (i=0;i<numchars;i++)
		if 	((i+1)%8==0) printf("%02X\n",str[i]);
		else 	printf("%02X ",str[i]);
	printf("\n");
}

int open_port(char *term)	{
	int fd;
	struct termios options;

	if ((fd = open(term, O_RDWR | O_NOCTTY | O_NDELAY))==-1)	{
		printf("Open failed!  Could not open port %s!\n",term);
		return 0;
	}

	tcgetattr(fd, &options);
	cfsetispeed(&options, B9600);
	cfsetospeed(&options, B9600);
	options.c_cflag |= (CLOCAL | CREAD);
	options.c_cflag &= ~PARENB;
	options.c_cflag &= ~CSTOPB;
	options.c_cflag &= ~CSIZE;
	options.c_cflag |= CS8;
	options.c_cflag &= ~CNEW_RTSCTS;
	options.c_lflag &= ~(ICANON | ISIG);
	options.c_lflag &= ~ECHO;	/* Finally, |= ECHO  to  &= ~ECHO*/
	options.c_iflag &= ~(INPCK | ISTRIP);
	options.c_iflag &= ~(IXOFF | IXON);
	options.c_iflag &= ~(ICRNL | INLCR | IGNCR | IUCLC);
	options.c_iflag |= IXANY;
	options.c_oflag &= ~OPOST;
	tcsetattr(fd, TCSAFLUSH, &options);
	return (fd);
}
