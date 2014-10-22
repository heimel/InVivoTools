function x=zero2nan(x)
%ZERO2NAN makes all zeros NaNs
%
% 2013-2014, Alexander Heimel
x = double(x);
x(x==0)=NaN;
