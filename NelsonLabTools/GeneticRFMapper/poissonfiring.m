function y=poissonfiring( x )
%POISSONFIRING returns random numbers taken from Poisson distribution with mean x
%
%  Y=POISSONFIRING( X )
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

y=x;
y(find(x<=0))=0.01;
y=poissrnd(y);
