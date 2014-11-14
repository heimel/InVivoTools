function res = isnormal( y )
%ISNORMAL checks if distribution is normal
%
% RES = ISNORMAL( Y )
%
%    shell around Shapiro-Wilk test
%
% 2014, Alexander Heimel

y = y(~isnan(y));

if all(diff(y)==0)
    res = 0;
    return
end

res = ~swtest( y );

