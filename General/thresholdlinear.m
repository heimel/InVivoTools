function y = thresholdlinear(x)
%THRESHOLDLINEAR returns x if x>0, otherwise 0
%
%  Y=THRESHOLDLINEAR( X )
%
%   2003-2013, Alexander Heimel
%

y = x;
y(x<0) = 0;
