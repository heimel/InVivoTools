/*=================================================================
 *
 * CONTSUMWAVESHELPER.C  Determines waveforms around triggers
 *  Part of the NeuralAnalysis package
 *  2003-08-06, Steve Van Hooser, vanhoosr@brandeis.edu
 * The calling syntax is:
 *
 *		[SUMWAVES] = CONTSUMWAVESHELPER(DATA,TRIGGERS,BIN,MAXBINS,NSAMPS)
 *
 *   TRIGGERS is the trigger time (in samples), and BIN is the bin
 *   number that each trigger corresponds to (1..MAXBINS).  NSAMPS is the
 *   number of
 *   samples to include.  MAXBINS is the number of bins.  No bounds
 *   checking is done to be sure the triggers and triggers+NSAMPS is in
 *   bounds, so checking should be done beforehand.
 *   SUMWAVES is a MAXBINS  X NSAMPS wave containing the sum of each
 *   set of samples around the triggers.  For example, if there
 *   are two triggers associated with bin 2, SUMWAVES(2,:) will
 *   be the sum of these samples.  This function is useful for calculating
 *   mean wavefroms.
 *
 *  There is no correponding .m file for this mex function, sorry.
 *
 *=================================================================*/
#include <math.h>
#include "mex.h"

#define	DATA	prhs[0] 
#define TRIGGERS prhs[1]
#define BINS prhs[2]
#define MAXBINS prhs[3]
#define NSAMPS prhs[4]
#define	SUMWAVES	plhs[0]

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

static void contsumwaveshelper(double data[],double triggers[], int numTrigs, double bins[],
		int maxbins, int numsamps, double sumwaves[])
{
	int i,j;

    for (i=0;i<numTrigs;i++) {
	   for (j=0;j<numsamps;j++) {
			sumwaves[(int)(j*maxbins+bins[i]-1)]+=data[(int)(triggers[i]+j-1)];
			/*mexPrintf("Index is %d\n",(int)((j-1)*maxbins+bins[i]-1));
			mexPrintf("Datapoint is %d\n",(int)data[(int)(triggers[i]+j-1)]);*/
	   }
	} 
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *data,*triggers,*nsamps,*bins,*maxbins; 
    double *sumwaves;
	int m,n;
    
    /* this is an internal function...let's dispense with argument checking*/
    
    data=mxGetPr(DATA); triggers=mxGetPr(TRIGGERS); bins=mxGetPr(BINS);
    nsamps=mxGetPr(NSAMPS); maxbins=mxGetPr(MAXBINS);
	m = mxGetM(TRIGGERS);
	n = mxGetN(TRIGGERS);

	/*mexPrintf("Size of triggers: %d x %d\n",m,n);
	mexPrintf("Maxbins is %d, nsamps is %d\n",(int)maxbins[0],(int)nsamps[0]);*/
    /* Create a matrix for the return argument */ 
    SUMWAVES = mxCreateDoubleMatrix((int)maxbins[0], (int)nsamps[0], mxREAL); 
    sumwaves = mxGetPr(SUMWAVES);
    contsumwaveshelper(data,triggers,MAX(m,n),bins,(int)maxbins[0],(int)nsamps[0],sumwaves);
    /*mexPrintf("Done with contsumwaveshelper.\n");*/
}


