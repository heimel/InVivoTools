/*=================================================================
 *
 * CONTTRIGGERHELPER.C  Determines waveforms around triggers
 *  Part of the NeuralAnalysis package
 *  2003-08-06, Steve Van Hooser, vanhoosr@brandeis.edu
 * The calling syntax is:
 *
 *		[INDWAVES] = CONTTRIGGERHELPER(DATA,TRIGGERS,NSAMPS)
 *
 *   TRIGGERS is the trigger time (in samples), NSAMPS is the
 *   number of samples to include.  No bounds checking is done
 *   to be sure the triggers and triggers+NSAMPS is in
 *   bounds, so checking should be done beforehand.
 *   INDWAVES is a length(TRIGGERS) X NSAMPS wave containing the
 *   set of samples around the triggers.  This function is useful
 *   for calculating mean wavefroms.
 *
 *  There is no correponding .m file for this mex function, sorry.
 *
 *=================================================================*/
#include <math.h>
#include "mex.h"

#define	DATA	prhs[0] 
#define TRIGGERS prhs[1]
#define NSAMPS prhs[2]
#define	INDWAVES	plhs[0]

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

static void conttriggerhelper(double data[],double triggers[], int numTrigs,
		int numsamps, double indwaves[])
{
	int i,j;
	/*double x1,x2;*/

    for (i=0;i<numTrigs;i++) {
	   for (j=0;j<numsamps;j++) {
			/*x1=indwaves[(int)(j*numTrigs+i)];
			mexPrintf("X1 is %f, %d\n",x1,(j*numTrigs+i));
			x2=data[(int)(triggers[i]+j-1)];
			mexPrintf("X2 is %f\n",x2);*/
			indwaves[(int)(j*numTrigs+i)]=data[(int)(triggers[i]+j-1)];
			/*mexPrintf("Index is %d\n",(int)(j*numTrigs+i-1));
			mexPrintf("Datapoint is %d\n",data[(int)(triggers[i]+j-1)]);*/
	   }
	   /*if (i>=0) { mexPrintf("Trigger number: %d\n",i); }*/
	} 
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *data,*triggers,*nsamps,*indwaves;
	int m,n;
    
    /* this is an internal function...let's dispense with argument checking*/
    
    data=mxGetPr(DATA);triggers=mxGetPr(TRIGGERS);nsamps=mxGetPr(NSAMPS);
	m=mxGetM(TRIGGERS); n=mxGetN(TRIGGERS);

	/*mexPrintf("Size of triggers: %d x %d\n",m,n);
	mexPrintf("nsamps is %d\n",(int)nsamps[0]);*/
    /* Create a matrix for the return argument */ 
    INDWAVES = mxCreateDoubleMatrix(MAX(m,n), (int)nsamps[0], mxREAL); 
    indwaves = mxGetPr(INDWAVES);
    conttriggerhelper(data,triggers,MAX(m,n),(int)nsamps[0],indwaves);
    /*mexPrintf("Done with conttriggerhelper.\n");*/
}


