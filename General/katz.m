function dimens = katz(x)
% Katz's Fractal Dimension: for measuring complexity of signal
% written by Mehran Ahmadlou & Alexander Heimel

N = length(x);

% data's envelop length (i.e., sum of the Euclidean distances between successive data points)
L = sum( sqrt(diff(x).^2+1));

% diameter of the data, i.e. Euclidean distance between first point
% and the point furthest away
d =  sqrt( max( (x(:)'-x(1)).^2+(0:N-1).^2 ));

dimens = log10(N-1)/(log10(N-1)+log10(d/L));