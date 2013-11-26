% XCORR2DLAG - 2-d cross-correlation computed at specified lags
%
%   XC = XCORR2DLAG(W1,W2,XLAGS,YLAGS)
%
%  Computes cross-correlation of two-dimensional matricies
%  W1 and W2 at the specified lags in x (XLAGS) and in y
%  (YLAGS).  This function is a MEX file written for speed
%  and therefore there is no error checking to make sure
%  W1 and W2 are the same size and that XLAGS and YLAGS
%  are in bounds.  If error checking is important then it
%  is best to compute it directly in matlab (e.g.,
%  sum(sum(W1(y1b:y1e,x1b:x1e).*W2(y2b:y2e,x2b:x2e))) ).
%
%  XC is a matrix LENGTH(YLAGS)xLENGTH(XLAGS).
