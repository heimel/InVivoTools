/*=================================================================
 *
 * DOTDISC.C	Performs dot discrimination for dotdiscriminator.
 *  Part of the NelsonLabTools package
 *  2002-08-21, Steve Van Hooser, vanhoosr@brandeis.edu
 * The calling syntax is:
 *
 *		[T] = DOTDISC(Y)
 *
 *  Look at the corresponding M-code, dotdisc.m, for help.
 *
 *=================================================================*/
#include <math.h>
#include "mex.h"

#define	Y_IN	prhs[1] 
#define DOTS_IN prhs[2]
#define	S_OUT	plhs[0]

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

static void dotdisc(double y[],int ylen,double *t[],int *numT,double dots[],
						int numdots)
{
	int ptsgood=0,i,j,m,earlydot=0,latedot=0,off,sg;
    double *T,thresh;

    T = 0;
    
    for (i=0;i<numdots;i++) {
       if (dots[i*3+2]<earlydot) earlydot = (int) dots[i*3+2];
       if (dots[i*3+2]>earlydot) latedot = (int) dots[i*3+2];
   /*mexPrintf("Dot %d: %g %g %g\n",i,dots[i*3+0],dots[i*3+1],dots[i*3+2]);*/
    }
    /*mexPrintf("Early and late dot:  %d,%d\n",earlydot,latedot);*/

    *numT = 0;

    for (i=-earlydot;i<(ylen-latedot);i++) { /* avoid window problems */
        m=1;
		for (j=0;m&(j<numdots);j++) { /* see if we have a dot match */
		  /* thresh=dots[j*3+0];sg=(int)dots[j*3+1];off=(int)dots[j*3+2];*/
           if (dots[j*3+1]>0) 
				m=m&(y[i+(int)dots[j*3+2]]>dots[j*3+0]);
           else m=m&(y[i+(int)dots[j*3+2]]<dots[j*3+0]);
        }
		if ((m==0)&(ptsgood>0)) {
			(*numT)++;
			T = (double *)realloc(T,(*numT)*sizeof(double));
			T[(int)(*numT)-1] = ceil(i-((double)ptsgood/2.0));
			ptsgood = 0;
		} else {if (m==1) { ptsgood = ptsgood++; }}
	}
	*t = T;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *y,*dots; 
    double *t,*newt;
    int numdots, numY, numT,i;
    
    /* this is an internal function...let's dispense with argument checking*/
    
    dots=mxGetPr(DOTS_IN); y=mxGetPr(Y_IN);
    numY = MAX(mxGetM(Y_IN),mxGetN(Y_IN)); numdots=mxGetN(DOTS_IN);
    /*mexPrintf("Number of dots: %d\n",numdots);*/
	/*mexPrintf("Size of y: %d\n",numY);*/
    dotdisc(y,numY,&t,&numT,dots,numdots); 
    /*mexPrintf("Done with dotdisc.\n");*/
    /* Create a matrix for the return argument */ 
    S_OUT = mxCreateDoubleMatrix(numT, 1, mxREAL); 
    newt = mxGetPr(S_OUT);
    /* copy the data into the new matrix */
    for (i=0;i<numT;i++) {newt[i]=t[i];}
    free(t);
}


