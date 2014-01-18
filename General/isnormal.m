function res = isnormal( y )
%ISNORMAL checks if distribution is normal
%
% RES = ISNORMAL( Y )
%
%    shell around Shapiro-Wilk test
%
% 2014, Alexander Heimel

res = ~swtest( y );

