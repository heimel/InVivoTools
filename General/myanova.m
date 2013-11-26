function [p,h,comp] = myanova(X, G, SIG)

%  MYANOVA - One-way analysis of variance with posthoc comparisons
%    MYANOVA performs a one-way ANOVA for comparing the means of two or more
%    groups of data.  It returns the p-value for the null hypothesis that the
%    means of the groups are equal.  If the null hypothesis is rejected,
%    then it makes posthoc comparisons with a modified t-test.
%
%    [P, H, COMP] = MYANOVA(X, G, [SIG]) has vector inputs X and G.  G contains
%    the group number for each point in X.  SIG is the significanc level to use
%    (default is 0.05).  P is the probability of the null hypothesis, H is
%    1 if the null hypothesis is rejected and 0 otherwise, and COMP is an
%    NxN matrix of significant comparisons among the groups, where N is the
%    total number of groups (determined by the number of unique elements in G).

if nargin>=3, sig = SIG; else, sig = 0.05; end;

grp = unique(G);
n = length(grp);
N = zeros(1,n);
M = zeros(1,n);
s_b2 = 0; %  between groups variance
s_w2 = 0; %  within groups variance
gm = mean(X);  % grand mean

 % compute between groups variance and within groups variance
for i=1:length(grp),
	inds = find(G==grp(i));
	N(i) = length(inds);
	M(i) = mean(X(inds));
	s_b2 = s_b2 + N(i) * (M(i)-gm)^2;
	s_w2 = s_w2 + (N(i)-1) * var(X(inds));
end;
s_b2 = s_b2/(n-1); s_w2 = s_w2/( sum(N)-n);

p = 1-fcdf(s_b2/s_w2,n-1,sum(N)-n);
h = p<sig;

comp = [];
if h==1,
  comp = zeros(n,n);
  for i=1:n, for j=1:n,
	if i~=j, % modified t-test for posthoc comparisons
	   cdfval=1-tcdf((M(i)-M(j))/(sqrt(s_w2*(1/N(i)+1/N(j)))),sum(N)-n);
	   comp(i,j) = 2*min(cdfval,1-cdfval); % b/c null hypothesis is M(i)==M(j)
	end;
  end; end; % for loops
end;
