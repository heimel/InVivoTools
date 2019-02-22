function [y,ind] = remove_outliers(y)
%REMOVE_OUTLIERS removes everything outside [Q1-1.5IQ Q3+1.5IQ]
%
% [Y, INCLUDE] = REMOVE_OUTLIERS(Y)
%
%     INCLUDE is a boolean vector indicating if a value is not an outlier
%
% 2016-2018, Alexander Heimel

q1 = prctile(y,25);
q3 = prctile(y,75);
iq = q3-q1;

ind = (y>=q1-1.5*iq & y<=q3+1.5*iq );
y = y(ind);

