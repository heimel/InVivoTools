function r=markfi(I)
tau_refr=0.002; % s
kappa = 5 ; %Hz

r=max(I,0);
r= kappa*log(cosh(r/kappa))./(1+tau_refr*kappa*log(cosh(r/kappa)));
