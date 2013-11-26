/*
dified standard Acq-IntClk-DigStartRef function to work on Olympus Fluoview system. The FVS-PSU unit outputs:
*
*	1st BNC: Sawtooth wave ramping up during each frame scan (0.72-0.95V)
*	2nd BNC: TTL down pulse wave starting on each frame scan (0.0-2.2V, width <1ms) 
*	3rd BNC: Sawtooth wave ramping up during each line scan (0.72-0.95V)
*	4th BNC: TTL down pulse wave starting on each line scan (0.0-2.2V, width <1ms)
* 
* This program let's the NIDAQ USB-6008 data acquisition card sample the sawtooth wave on the first BNC with a frequency of 1000Hz 
* for a variable period of time in seconds (1st argument, e.g. 10) and outputs timestamps for each start of a new frame scan 
* to an output txt file (2nd argument, e.g. twophotontimes.txt)
*
* The amplitude of the sawtoothwave is iteratively compared to it's previous value and when the difference exceeds the noise level (fixed on 0.1V), 
* it will detect a trough and thus the start of a frame scan, at which time a timestamp is recorded.
*
* AH & DV, 25-03-2010
*********************************************************************/

#include <stdio.h>
#include <stdarg.h>

#include "NIDAQmx.h" 

#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

#define NOISE_LEVEL 0.07  // in volt
#define SAMPLE_FREQUENCY 10000.0 // in Hertz
#define PULSEWIDTH 0.003  // pulsewith in seconds

void usagemessage( void){
	printf("usage:\nacquire_twophotontimes SECONDS FILEPATHNAME\n");
	printf("      e.g. twophotontimes 10 \"C:\\twophotontimes.txt\"\n");
}


void vcustomerror(char *fmt, va_list vl) {
	vprintf(fmt, vl);
	usagemessage();
	printf("Press key to exit.\n");
	getchar();	
	exit(-1);
}
void customerror(char *fmt, ...) {
	va_list vl;
	va_start(vl, fmt);
	vcustomerror(fmt, vl);
	va_end(vl);
}


int main(int argc, char *argv[]){
	int			sampletime = 1; // in s
	int			numSamples;
	int32       error = 0;
	TaskHandle  taskHandle = 0;
	int32       read;
	float64     *data;
	char		filename[2048] = {'\0'};
	char        errBuff[2048] = {'\0'};
	int	recording = 1;
	float64     state = -10; // used to detect edge  
	FILE *pFile; // file id for output twophoton times file
	
	if(argc<2){
		customerror("Not enough arguments given.");
	}

    sampletime = atoi( argv[1]);
	if(sampletime<1){
		customerror("Sampletime given is incorrect.");
	}

	strncpy(filename,argv[2],2048);
	
	// calculate number of samples needed
	numSamples = sampletime *(int) (SAMPLE_FREQUENCY+1);

	// allocating buffer
	data = (float64*)malloc( numSamples *sizeof( float64 ));

	// open file
	pFile = fopen(filename,"w");
	if (pFile==NULL){
		customerror("Failed to open %s", filename);
	}

/*
	char curdir[FILENAME_MAX];
	memset(curdir, 0, sizeof(curdir));
	if (!GetCurrentDir(curdir, sizeof(curdir))) {
		customerror("Couldn't get current directory!");
	}
	printf("Current directory: %s\n", curdir);
*/
	printf("Filename: %s\n", filename);

	// DAQmx Configure Code
	printf("DAQmx Configure Code\n");
	DAQmxErrChk (DAQmxCreateTask("",&taskHandle));
	DAQmxErrChk (DAQmxCreateAIVoltageChan(taskHandle,"Dev1/ai0","",DAQmx_Val_Cfg_Default,-10.0,10.0,DAQmx_Val_Volts,NULL));
	DAQmxErrChk (DAQmxCfgSampClkTiming(taskHandle,"",SAMPLE_FREQUENCY,DAQmx_Val_Rising,DAQmx_Val_FiniteSamps,numSamples));
	//DAQmxErrChk (DAQmxCfgDigEdgeStartTrig(taskHandle,"/Dev1/PFI0",DAQmx_Val_Rising));
	//DAQmxErrChk (DAQmxCfgDigEdgeRefTrig(taskHandle,"/Dev1/PFI0",DAQmx_Val_Rising,100));

	// DAQmx Start Code
	printf("DAQmx Start Code\n");
	DAQmxErrChk (DAQmxStartTask(taskHandle));
	printf("Acquiring for %d seconds a total of %d samples at %f Hz\n", sampletime, numSamples, SAMPLE_FREQUENCY);

	// DAQmx Read Code
	printf("DAQmx Read Code\n");
	DAQmxErrChk (DAQmxReadAnalogF64(taskHandle,-1,sampletime+1,0,data,numSamples,&read,NULL));
	printf("read = %d\n",read);
	parse_times(data, read, &state, pFile);
	if( read<numSamples ){
		customerror("Error occurred. Acquired fewer than the requested number of samples. ");
	}
	
	printf("Acquired %d points\n",read);

Error:
	if( DAQmxFailed(error) )
		DAQmxGetExtendedErrorInfo(errBuff,2048);
	if( taskHandle!=0 ) {
		// DAQmx Stop Code
		DAQmxStopTask(taskHandle);
		DAQmxClearTask(taskHandle);
	}
	if( DAQmxFailed(error) )
		printf("DAQmx Error: %s\n",errBuff);

	free(data);
	fclose(pFile);

	//printf("End of program, press Enter key to quit\n");
	//getchar();
	return 0;
}


int parse_times(float64* data,int numSamps,float64 *pstate, FILE *pFile )
{
  int i;
  float64 prev_eventtime = -1;
  float64 eventtime;

  for(i=0;i<numSamps;i++){
	//printf("%d %f\n",i,data[i]);
	//fprintf(pFile,"%d %f\n",i,data[i]);
	  //if(data[i]>THRESHOLD_HIGH){
		if( data[i]<(*pstate-NOISE_LEVEL) ){
			eventtime = i/SAMPLE_FREQUENCY;
			if(eventtime > prev_eventtime + PULSEWIDTH){
				printf("%.4f %.4f %.4f\n",eventtime,*pstate,data[i]);
				fprintf(pFile,"%.4f %.4f\n",eventtime,eventtime-prev_eventtime);
				prev_eventtime = eventtime;
			}
		}
		*pstate = data[i];
	//}else if(data[i]<THRESHOLD_LOW)
	//	*pstate = 0;
  }
  return 1;
}



