function err=shifted_gaussian_error( params, x, y, ste)
%SHIFTED_GAUSSIAN_ERROR computes squared error of a shifted gaussian to data
%
%  ERR=SHIFTED_GAUSSIAN_ERROR( PARAMS, X, Y)
%  ERR=SHIFTED_GAUSSIAN_ERROR( PARAMS, X, Y, STE)
%
%     PARAMS =    (see HELP SHIFTED_GAUSSIAN)
%     X = x values of data
%     Y = y values of data
%
%   also includes an extra cost for small sigma
%  
%  2003, Alexander Heimel, (heimel@brandeis.edu)
%
   
yfit=shifted_gaussian(params,x);
err=(yfit-y);
if nargin==4
%  err=err./((ste+0.001)./(y+0.001)); 
  err=err./ste;
end
err=err*err';
err=err+ 0.05*err/(abs(params(4))+0.1);
