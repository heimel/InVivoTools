function x=zero2nan(x)
%ZERO2NAN makes all zeros NaNs
%
% 2013, Alexander Heimel

x(x==0)=NaN;
