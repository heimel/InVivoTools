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
%  2003-2016, Alexander Heimel
%

yfit = dog(params,x);
err = (yfit-y);
if nargin==4
    err = err./((ste+0.001)./(y+0.001));
    % this way relative size of error counts
    % could be done quicker, but less clear: err=yfit/y-ones(size(y));
end
err = err*err';

[minx,ind] = min(x);
err = err + (y(ind)-dog(params,min(x)))^2; % put extra emphasis on lowest x

yfit = dog(params,0);
err = err +  err*(abs(yfit)-yfit); % punish negative y(0)

% err=err + 10*yfit^2; % punish explosions close to 0
% err=err + (yfit-dog(params,minx))^2; % punish explosions close to 0

maxx = max(x);
err = err + (dog(params,maxx*10)-dog(params,maxx))^2; % punish explosions after max(x)

%err = err + thresholdlinear(dog(params,maxx*1.1)-dog(params,maxx)); % punish positive slope after max(x)

% punish negative parameters
err = err + thresholdlinear( -params(2) );
err = err + thresholdlinear( -params(3) );
err = err + thresholdlinear( -params(4) );
err = err + thresholdlinear( -params(5) );

% punish bigger si than si
err = err + thresholdlinear( params(5) - params(3));
