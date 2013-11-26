function err=von_mises_error( params, x, y, ste)
%VAN_MISES_ERROR computes squared error of a shifted gaussian to data
%
%  ERR=VAN_MISES_ERROR( PARAMS, X, Y)
%  ERR=VAN_MISES_ERROR( PARAMS, X, Y, STE)
%
%     PARAMS =    (see HELP VAN_MISES)
%     X = x values of data
%     Y = y values of data
%
%   also includes an extra cost for small sigma
%  
%  2003-2013, Alexander Heimel, (heimel@brandeis.edu)
%
   
yfit=von_mises(params,x);
err=(yfit-y);
if nargin==4
%  err=err./((ste+0.001)./(y+0.001)); 
  err=err./ste;
end
err=err*err';

%err=err - 0.005*size(x,1)*(min(abs(params(4)),180))^0.3;
err = err + 0.1*abs(max(y))*size(x,1)*params(4)^-0.5;