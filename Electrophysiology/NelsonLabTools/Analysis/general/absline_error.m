function err=absline_error( params, x, y, ste)
%ABSLINE_ERROR compute error of the absolute of a straight line fit 
%
%  ERR=ABSLINE_ERROR( PARAMS, X, Y, STE)
%
%     PARAMS = [ A B ]   (see y=Ax+B
%     X = x values of data
%     Y = y values of data
%
%  
%  2004, Alexander Heimel
%

yfit=abs( params(1)*x + params(2));



err=(yfit-y);

if nargin==4
  %err=err./((ste+0.001)./(y+0.001)); 
  %err=err./(ste+0.001);
  % this way absoltute size of error counts
  % could be done quicker, but less clear: err=yfit/y-ones(size(y));
end
err=err*err';

%err=err+params(1)*100;
