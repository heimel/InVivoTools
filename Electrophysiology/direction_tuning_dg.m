function y = direction_tuning_dg(par,x)
%DIRECTION_TUNING_DG computes double gaussian for direction tuning data
%
%  par = [c,rp,rn,sigma,theta_pref)
%  x is angles in degrees
%
%  See Mazurek et al. Fronters
%
% 2021, Alexander Heimel

c = par(1);
rp = par(2);
rn = par(3);
sigma = par(4);
theta_pref = par(5);

angdir = @(x) min([abs(x); abs(x-360); abs(x+360)],[],1);

y = c + ...
    rp * exp(-angdir(x-theta_pref).^2/(2*sigma^2)) + ...
    rn * exp(-angdir(x+180-theta_pref).^2/(2*sigma^2));
    
