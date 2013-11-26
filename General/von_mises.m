function r=von_mises(par,x)
%VON_MISES returns Von Mises (circular gaussian) function
%
%    R=VON_MISES(PAR,X)
%
%    PAR = [ORTH_RATE PEAK_RATE MU SIGMA  ] 
%    X is input variable vector
%
%    R = PAR(1) + PAR(2)*EXP( ( cos(2(X-PAR(3))) -1 )/PAR(4) )
%
%  2003, Alexander Heimel (heimel@brandeis.edu)


r= par(1)+(par(2)-par(1))*exp((cos( 2*(x-par(3))*2*pi/360    )-1)/par(4)^2);
%r= par(2)*exp((cos( 2*(x-par(3)))-1)/par(4)^2);

  
