function y = remove_outliers(y)
%REMOVE_OUTLIERS removes everything outside [Q1-1.5IQ Q3+1.5IQ]
%
% 2016, Alexander Heimel

q1 = prctile(y,25);
q3 = prctile(y,75);
iq = q3-q1;
y = y ( y>=q1-1.5*iq & y<=q3+1.5*iq );
