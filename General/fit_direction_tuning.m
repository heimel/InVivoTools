function [par,fity] = fit_direction_tuning(x,y,fitx,verbose)
% FIT_DIRECTION_TUNING fits direction tuning curve following Mazurek et al.
%
%  [PAR,FITY] = FIT_DIRECTION_TUNING(X,Y,FITX,VERBOSE)
%
%  X is angles in degrees
%  Y is responses
%
%  PAR = [c,rp,rn,sigma,theta_pref)
%
%  FITY is result of fit if FITX is not empty
%
%  see Mazurek et al. Frontiers
%
% 2021-2022, Alexander Heimel


if nargin<3
    fitx = [];
end

if nargin<4 || isempty(verbose)
    verbose = false;
end

dx = median(diff(x))/3;

[m,ind] = max(y);
par0 = [min(y) m-min(y) m-min(y) 30 x(ind)];
tuning_error = @(par) sum((y-direction_tuning_dg(par,x)).^2) + ...
    thresholdlinear(-par(4)+dx) + ...
    thresholdlinear(par(4)-180) + ...
    0.1*(par(5)-x(ind))^2 + ...
    thresholdlinear(-par(2)) + thresholdlinear(-par(3));

par = fminsearch( @(p) tuning_error(p),par0);

if ~isempty(fitx)
    fity = direction_tuning_dg(par,fitx);
else
    fity = [];
end

if verbose
    figure
    plot(x,y,'o');
    hold on
    xf = 0:360;
    plot(xf,direction_tuning_dg(par,xf),'-');
end
