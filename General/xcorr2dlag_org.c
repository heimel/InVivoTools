/*=================================================================
 *
 * XCORR2DLAG.C	Cross-correlation at given lags
 *  2006-02-28, Steve Van Hooser, vanhooser@neuro.duke.edu
 * The calling syntax is:
 *
 *		[XC] = XCORR2DLAG(W1,W2,XLAGS,YLAGS)
 *
 *  Computes 2D cross-correlation of W1 and W2 at the lags
 *  specified in vectors XLAGS and YLAGS.
 *  Look at the corresponding M-code, xcorr2dlag.m, for help.
 *
 *=================================================================*/

#include <math.h>
#include "mex.h"

#define	W1_IN	prhs[0] 
#define	W2_IN	prhs[1] 
#define XLAGS 	prhs[2]
#define YLAGS 	prhs[3]
#define	XC_OUT	plhs[0]

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

static void xcorr2dlags(double w1[],double w2[],int wr,int wc,double xlags[],int xn,double ylags[],int yn,double *XC[])
{
	int x,y,x_, y_,start1x,start2x,end1x,end2x,start1y,start2y,end1y,end2y;
	int XClen = xn * yn;
	(*XC) = (double*)malloc(XClen*sizeof(double));

	for (x=0;x<xn;x++) {
		for (y=0;y<yn;y++) {
			(*XC)[y+yn*x] = 0;
			if (xlags[x]>=0) {
				start1x=xlags[x];end1x=wc-1;start2x=0;end2x=wc-1-xlags[x];
			} else {
				start1x=0;end1x=wc-1+xlags[x];start2x=-xlags[x];end2x=wc-1;
			}
			if (ylags[y]>=0) {
				start1y=ylags[y];end1y=wr-1;start2y=0;end2y=wr-1-ylags[y];
			} else {
				start1y=0;end1y=wr-1+ylags[y];start2y=-ylags[y];end2y=wr-1;
			}
			/*mexPrintf("\nXlag : %f , Ylag: %f\n", xlags[x], ylags[y]);
			mexPrintf("Start1x : %d , End1x : %d\n", start1x, end1x);
			mexPrintf("Start1y : %d , End1y : %d\n", start1y, end1y);
			mexPrintf("Start2x : %d , End2x : %d\n", start2x, end2x);
			mexPrintf("Start2y : %d , End2y : %d\n", start2y, end2y);*/
			for (x_=start1x;x_<=end1x;x_++) {
				for (y_=start1y;y_<=end1y;y_++) { 
					(*XC)[y+yn*x]+=w1[y_+wr*x_]*w2[start2y+y_-start1y+wr*(start2x+x_-start1x)];
				}
			}
		}
	}
	return;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )
     
{ 
    double *w1,*w2,*ylags,*xlags,*newxc; 
    double *xc;
    int i,wr,wc,xn,yn;
    
    /* this is an internal function...let's dispense with argument checking*/
    /*   assumptions:  size w1==size w2 */

    /*mexPrintf("Beginning\n");*/
    if (nrhs<4) mexErrMsgTxt("Error in XCORR2DLAG:  four input arguments required.");
 
    w1=mxGetPr(W1_IN); w2=mxGetPr(W2_IN);
    wr= mxGetM(W1_IN); wc=mxGetN(W1_IN);
    /*mexPrintf("Rows of w1: %d\n",wr);*/
    xlags=mxGetPr(XLAGS); ylags=mxGetPr(YLAGS);
    xn = MAX(mxGetM(XLAGS),mxGetN(XLAGS)); yn = MAX(mxGetM(YLAGS),mxGetN(YLAGS));
    /*mexPrintf("Size of xlags: %d\n",xn);
    mexPrintf("Size of ylags: %d\n",yn);
    mexPrintf("Starting mex file.\n");*/
    xcorr2dlags(w1,w2,wr,wc,xlags,xn,ylags,yn,&xc); 
    /*mexPrintf("Done with xcorr2dlag.\n");*/
    /* Create a matrix for the return argument */ 
    XC_OUT = mxCreateDoubleMatrix(yn, xn, mxREAL); 
    newxc = mxGetPr(XC_OUT);
    /* copy the data into the new matrix */
    for (i=0;i<xn*yn;i++) {newxc[i]=xc[i];}
    free(xc); 
    return;
}


