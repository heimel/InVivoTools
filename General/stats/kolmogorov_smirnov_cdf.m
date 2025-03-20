function cdf = kolmogorov_smirnov_cdf(x,tol)

% KOLMOGOROV_SMIRNOV_CDF (X, TOL)
% Return the CDF at X of the Kolmogorov-Smirnov distribution,
%	        Inf
%	Q(x) =  SUM    (-1)^k exp(-2 k^2 x^2)
%		  k = -Inf
% for X > 0.
%
% The optional parameter TOL specifies the precision up to which the
% series should be evaluated;  the default is TOL = `eps'.
%
% Ported from octave 2.1.35

eps = 2.220e-16;

if nargin==1, tol = eps; end;

[nr, nc] = size (x);
if (min (nr, nc) == 0)
	error ('kolmogorov_smirnov_cdf: x must not be empty');
end

n   = nr * nc;
x   = reshape (x, 1, n);
cdf = zeros (1, n);
ind = find (x > 0);
if (length (ind) > 0)
	y   = x(ind);
	K   = ceil (sqrt (- log (tol) / 2) / min (y));
	k   = (1:K)';
	A   = exp (- 2 * k.^2 * y.^2);
	odd = find (rem (k, 2) == 1);
	A(odd,:) = -A(odd,:);
	cdf(ind) = 1 + 2 * sum (A);
end
cdf = reshape (cdf, nr, nc);
