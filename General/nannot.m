function y = nannot(x)
%NANNOT 
%
% 2014, Alexander Heimel

nans = isnan(x);
x(nans) = 0;
y = double(not(x));
y(nans) = NaN;