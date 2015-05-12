function err=dog_error( params, x, y, ste)
%DOG_ERROR computes squared error of difference of gaussians to data
%
%  ERR=DOG_ERROR( PARAMS, X, Y)
%  ERR=DOG_ERROR( PARAMS, X, Y, STE)
%
%     PARAMS = [ R0 RE SE RI SI ]   (see HELP DOG)
%     X = x values of data
%     Y = y values of data
%
%     Extra error is given for negative values at 0
%  
%  2003, Alexander Heimel, (heimel@brandeis.edu)
%
 
yfit=dog(params,x);
err=(yfit-y);
if nargin==4
  err=err./((ste+0.001)./(y+0.001)); 
  % this way relative size of error counts
  % could be done quicker, but less clear: err=yfit/y-ones(size(y));
end
err=err*err';

yfit=dog(params,[0]);
err=err +  err*(abs(yfit)-yfit); %+ 0.1*err*sum(abs(params)-params );
