function x = given(x) 
%GIVEN returns 0 for NaN entries, and 1 otherwise
%
% 2014, Alexander Heimel

x = zero2nan(x);
x(~isnan(x)) = 1;