function r=dog(par,x)
%DOG returns difference of gaussians 
%
%    R = DOG(PAR, X)
%
%    PAR = [ R0 RE SE RI SI ] 
%    
%    X is input variable vector
%    R0 is baseline response
%    RE is maximum response of positive gaussian
%    SE is standard deviation of positive gaussian
%    RI is maximum response of negative gaussian
%    SI is standard deviation of negative gaussian
%
% 200X-2019 Alexander Heimel

par=abs(par);
r = par(1)+ par(2).*exp( -x.^2/2./par(3)^2) - par(4) .* exp( -x.^2/2./par(5)^2);
