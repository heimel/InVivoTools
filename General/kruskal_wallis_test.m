function [pval, k, df] = kruskal_wallis_test(varargin)
%  KRUSKAL_WALLIS_TEST - Kruskal-Wallis one-factor analysis of variance
%  Perform a Kruskal-Wallis one-factor "analysis of variance".
%
%  [PVAL,K,DF]=KRUSKAL_WALLIS_TEST(X1, ..., XK)
%
%  Suppose a variable is observed for @var{k} > 1 different groups, and
%  let X1, ..., XK be the corresponding data vectors.
%
%  Under the null hypothesis that the ranks in the pooled sample are not
%  affected by the group memberships, the test statistic K is
%  approximately chi-square with DF = K - 1 degrees of freedom.
% 
%  The p-value (1 minus the CDF of this distribution at K) is
%   returned in PVAL}.
%
%  If no output argument is given, the p-value is displayed.
%   [From Octave 2.5.1]
%  Author: KH <Kurt.Hornik@ci.tuwien.ac.at>
%  Description: Kruskal-Wallis test
pval = []; k = []; df = [];

m = nargin;

size(varargin);
if m<2, error('[pval,k,df] = kruskal_wallis_test(x1,...)'); end;

n = [];
p = [];

for i=1:m,
	x = varargin{i};
	if size(x,1)~=1&size(x,2)~=1,
		error('kruskal_wallis_test: all arguments must be vectors');
	end;
	l = length(x);
	n(end+1) = l;
	p = cat(2,p,reshape(x,1,l));
end;
r = ranks2(p);

k = 0;
j = 0;
for i=1:m,
  k = k + (sum (r ((j + 1) : (j + n(i))))) ^ 2 / n(i);
  j = j + n(i);
end

n    = length (p);
k    = 12 * k / (n * (n + 1)) - 3 * (n + 1);
df   = m - 1;
pval = 1 - chi2cdf (k, df);

if (nargout == 0)
    sprintf('pval: %g\n', pval);
end

