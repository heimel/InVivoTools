function y = mynansum(x)
%NANSUM Sum, ignoring NaNs.
%   Y = NANSUM(X) returns the sum of X, treating NaNs as missing values.
%      Only works for vectors. All NaNs will return NaN. Unlinke NANSUM,
%      which returns 0.
%      Empty X returns empty. 
%
% 2015, Alexander Heimel, based on MathWorks NANSUM
if isempty(x)
    y = [];
elseif all(isnan(x))
    y = NaN;
else
    x(isnan(x)) = [];
    y = sum(x);
end