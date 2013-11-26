function y = nansem(x)
%NANSEM Standard error of the mean, ignoring NaNs.
%   Y = NANSEM(X)
%

if numel(x)==length(x)
    x = x(~isnan(x));
    y = sem(x);
else
    error('NANSEM:MORETHANONED','NANSEM only allows one-dimensional data');
end