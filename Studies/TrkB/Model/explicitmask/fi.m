function r=fi(I)

% thresholdlinear
%r=max(I,0);

% mark's
%tau_refr=0.002; % s
%kappa = 5 ; %Hz
%r= kappa*log(cosh(I/kappa))./(1+tau_refr*kappa*log(cosh(I/kappa)));

%powerlaw
n=2;
r=max(I,0)^n;