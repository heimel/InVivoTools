function [STATS,h] = manova_steve(X,g,al)

% MANOVA - Multivariate Analysis of Variance
%
%  [STATS,H] = MANOVA(X,G), or
%  [STATS,H] = MANOVA(X,G,ALPHA)
%
%  Determines whether the means of groups of multivariate data points are the
%  same, using Wilks' criterion.  Each N-dimensional data point is a row in X,
%  so that X is NxP, where P is the total number of data points.  Each data
%  point belongs to a group, indicated in vector G, which should be 1XP.
%  ALPHA is level of significance, and, If ALPHA is not given, 0.01 is assumed.
%  
%  STATS is a struct with the following elements:
%
%    DF_between = degrees of freedom among samplesm, or (K-1), K==num of groups
%    DF_within  = degrees of freedom within samples, or N-K
%    DF_TOTAL   = total degrees of freedom N-1
%    B          = matrix of sum of squares and products (SSP) between samples
%    W          = matrix of SSP within samples
%    T          = matrix of total SSP, note that T==W+B
%    ratio      = |W|/|T|, or ratio to be compared to Wilks' statistic
%    P          = Probability of data under hypothesis that means are equal
%    H          = 0 if means are SAME, 1 if DIFFERENT
%    X__        = Grand mean of data
%    X_         = Mean of each group (KxP)
%    N          = Number of items in each group (Kx1)
%    E          = Eigenvalues for canonical variate projection (inv(W)*B)
%    V          = Eigenvectors corresp. to these eigenvalues
%    VV         = Eigenvectors normalized (by W/(N-K)) for canonical v. proj.
%
%  See Chapter 12 of _Multivariate Analysis_, KV Mardia, JT Kent, JM Bibby,
%  Academic Press, London, 1979.
% 
%  Note:  The eigenvector corresponding to the largest eigenvalue of inv(W)*B 
%  is the first canonical variate or Fisher's linear discriminant function.
%  Projecting onto this variate is useful for visualizing the differences among
%  groups of data.  The other canonical variates are the eigenvectors
%  corresponding to the eigenvalues in descending order of magnitude.
%  (See sec. 11.5 of above book.)
%
%  Steve Van Hooser, 2003

if nargin==3, alpha = al; else, alpha = 0.01; end;

grps = unique(g);
k = length(grps);
p = size(X,2);
W = zeros(p); B = zeros(p);
x__ = mean(X); % grand mean
x_ = zeros(k, p); % a place to store the group means
n = zeros(length(grps),1); % number of items in each group
for i=1:k,
  inds = find(g==grps(i));
  n(i) = length(inds);
  x_(i,:) = mean(X(inds,:));
  x_m= repmat(x_(i,:),n(i),1);
  W = W + (X(inds,:)-x_m)'*(X(inds,:)-x_m); % 'within' sum of squares
  B = B + n(i)*(mean(X(inds,:))-x__)'*(mean(X(inds,:))-x__); %'between'
end;

x__m = repmat(x__,sum(n),1);
T = (X-x__m)'*(X-x__m); % Total sums of squares, W + B = T

df_among = k-1;
df_within= sum(n)-k;
df_tot = df_among + df_within;

r = det(W)/det(T);
%lll = real(eig(B/W));  %alternate way of getting r
%lll(lll<1e-13)=0;
%r = prod(1./(1+lll));
m = sum(n)-k;

 % use Bartlett's approx of Wilt's lambda (see sec 3.7 in reference)
 WL = -(m-0.5*(p-(k-1)+1))*log(r);
prob = 1-chi2cdf(WL,(k-1)*p);

h=(prob<alpha);
V = []; E = []; VV = [];

try,   % sometimes eigenvalue projection fails due to convergence problems
	[V,E] = eig(inv(W)*B);
	VV = zeros(size(V));
	for i=1:p,
	   VV(:,i) = V(:,i)/(V(:,i)'*(W/m)*V(:,i)); % normalize canonical variates
	end;
end;

STATS.DF_between=df_among;STATS.DF_within=df_within;STATS.DF_total=df_tot;
STATS.W=W;STATS.B=B;STATS.T=T;STATS.ratio=r;STATS.P=prob;STATS.H=h;
STATS.X_=x_;STATS.X__=x__;STATS.N=n;STATS.E=diag(E);STATS.V=V; STATS.VV=VV;
STATS.WL = WL;

  % let xx=X-repmat(mean(X), size(X,1),1); then xx'*xx == size(X,1)*cov(X,1)
