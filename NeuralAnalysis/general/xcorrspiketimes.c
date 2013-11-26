/*=================================================================
 *
 * XCORRSPIKETIMES.C  Computes cross-correlation between two spike trains
 *  Part of the NeuralAnalysis package
 *  2003-09-19, Steve Van Hooser, vanhoosr@brandeis.edu
 * The calling syntax is:
 *
 *		[XCORR] = XCORRSPIKETIMES(X1,X2,TIMEBINS)
 *
 *   X1 and X2 are spike times, and TIMEBINS is a list of time bins 
 *   over which to compute the cross-correlation
 *   (e.g., -0.100:0.001:0.100 + 0.0005).  The 't'th entry in XCORR
 *   is the number of spikes in X2 that fall between TIMEBINS(t) and
 *   TIMEBINS(t+1), so XCORR has size 1xLENGTH(TIMEBINS)-1.
 *   X1,X2, and TIMEBINS are expected to be sorted and in increasing
 *   order.
 *   
 *   
 *   See also: XCORR
 *
 *  There is no correponding .m file for this mex function, sorry.
 *
 *=================================================================*/
#include <math.h>
#include "mex.h"

#define	X1	prhs[0] 
#define X2 prhs[1]
#define TIMEBINS prhs[2]
#define XCORR	plhs[0]

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

static void xcorrspiketimes(double x1[],int x1s, double x2[], int x2s,
	double timebins[],int tbs,long int xcorr[]) 
{
	int i,j,t; /* i for looping over X1, j for looping over X2 */

	if (x2s==0) return;
    for (t=0;t<tbs-1;t++) {
		j = 0;
		for (i=0;i<x1s;i++) {
			while ((j<x2s)&(x2[j]<x1[i]+timebins[t])) j++;
			if (j<x2s) {
				while ((j<x2s)&(x2[j]>=(x1[i]+timebins[t]))&(x2[j]<x1[i]+timebins[t+1])) { xcorr[t]++; j++; }
			}
		}

	}
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *x1,*x2,*timebins,*xcorr;
	int m1,n1,m2,n2,mt,nt,i;
	long int *xcorr_int;
    
    /* this is an internal function...let's dispense with argument checking*/
    
    x1=mxGetPr(X1); x2=mxGetPr(X2);
    timebins=mxGetPr(TIMEBINS); mt=mxGetM(TIMEBINS);nt=mxGetN(TIMEBINS);
	m1=mxGetM(X1);n1=mxGetN(X1);m2=mxGetM(X2);n2=mxGetN(X2);

	/*mexPrintf("Size of X2: %d x %d\n",m2,n2);*/
	/*mexPrintf("nsamps is %d\n",(int)nsamps[0]);*/
    /* Create a matrix for the return argument */ 
    XCORR = mxCreateDoubleMatrix(MAX(mt,nt)-1, 1, mxREAL); 
    xcorr = mxGetPr(XCORR);
	xcorr_int=malloc(sizeof(long int)*MAX(mt,nt));
	for (i=0;i<MAX(mt,nt)-1;i++) xcorr_int[i]=0;
    xcorrspiketimes(x1,MAX(m1,n1),x2,MAX(m2,n2),timebins,MAX(mt,nt),xcorr_int);
	for (i=0;i<MAX(mt,nt)-1;i++) xcorr[i] = (double)xcorr_int[i];
	free(xcorr_int);
    /*mexPrintf("Done with xcorrspiketimes.\n");*/
}


