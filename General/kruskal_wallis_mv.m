function [pval,kw,df] = kruskal_wallis_mv(varargin)
%  KRUSKAL_WALLIS_MV(VARARGIN)
%  Perform a Kruskal-Wallis one-factor 'analysis of variance' for multivariate
%  data.
%  
%  [PVAL,KW,DF] = KRUSKAL_WALLIS_MV(X1, ..., XK)
%
%  Returns the probability (PVAL) of the null hypothesis that the
%  distributions of X1, ..., XK are equal.  The multivariate points Xi should
%  be arranged in column form.  The KW statistic and degrees of freedom DF
%  are returned.  The Kruskal-Wallis test is a rank
%  test based on the order of the datapoints rather than their value
%  (see ANOVA1).  We implement the test described by Choi and Marden and
%  choose the kernel to be (X-Y)/||(X-Y)|| (see the reference).
%
%  Reference: Choi and Marden, J. Amer. Stat. Assoc., 92:1581-1590
%
%  warning: this has been tested for normal distributions and seems to
%  perform reasonably, but I could not find example data for which the
%  authors had performed analysis; upshot: this is not 100% tested

pval = [];
K = nargin;
N = zeros(1,K);

if K<2, error('[pval] = kruskal_wallis_mv(x1,...)'); end;

p = []; G = []; data = [];

for k=1:K,
  x = varargin{k};
  N(k) = size(x,1);
  if isempty(p), p = size(x,2);
  else, if size(x,2)~=p, error('data points must be of same dimension');end;end;
  data = [ data ; x];
  G = [ G; k*ones(N(k),1)];
end;

 % compute ranks
r = zeros(sum(N),p); rg = r;
for i=1:sum(N),
  chunk=repmat(data(i,:),sum(N),1)-data;
  chunk = chunk./(repmat(sum(sqrt(chunk.*chunk),2),1,p)+1e-8);
  r(i,:) = mean(chunk);
  g = find(G==G(i));
  chunk = repmat(data(i,:),N(G(i)),1)-data(g,:);
  chunk = chunk./(repmat(sum(sqrt(chunk.*chunk),2),1,p)+1e-8);
  rg(i,:) = mean(chunk);
end;

 % compute mean ranks, sigma_n's, kw stat
sigma_n = 0;
for k=1:K,
  g = find(G==k);
  r_{k} =  mean(r(g,:));
  for i=1:length(g),
    sigma_n=sigma_n+rg(i,:)'*rg(i,:);
  end;
end;
sigma_n = sigma_n/(sum(N)-K);

 %compute kw stat
kw = 0;
for k=1:K,
  kw = kw + N(k) * r_{k} * inv(sigma_n) * r_{k}';
end;

df = p*(K-1);
pval = 1-chi2cdf(kw,df);
