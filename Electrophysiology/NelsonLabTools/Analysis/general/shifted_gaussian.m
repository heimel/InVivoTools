function r=shifted_gaussian(par,x)
%SHIFTED_GAUSSIAN returns shifted gaussian
%
%    R=SHIFTED_GAUSSIAN((PAR,X)
%
%    PAR = [ ORTH_RATE PEAK_RATE MU SIGMA  ] 
%    X is input variable vector
%
%    R = PAR(1) + (PAR(2)-PAR(1))*EXP( - (X-PAR(3))^2/2/SIGMA^2 );
%
%  2003, Alexander Heimel (heimel@brandeis.edu)
  
r= par(1) + (par(2)-par(1))*exp( - (x-par(3)).^2/2/par(4)^2 );

  
