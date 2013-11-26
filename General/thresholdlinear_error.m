function err=thresholdlinear_error(params,x,y,ste)
%THRESHOLDLINEAR_ERROR computes squared error of thresholdlinear fit to data
%
%    ERR=THRESHOLDLINEAR_ERROR(PARAMS,X,Y,STE)
%
%  2005, Alexander Heimel
%
  
  yfit=thresholdlinear(params(1)*x+params(2));
err=(yfit-y);
if nargin==4
  err=err./((ste+0.001)./(y+0.001)); 
  % this way relative size of error counts
  % could be done quicker, but less clear: err=yfit/y-ones(size(y));
end
err=err*err';


