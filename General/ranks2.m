function y = ranks (x)
% RANKS - Returns vector of ranks of X adjusted for ties
%
% Y = RANKS(X)
%
% If X is a vector, return the (column) vector of ranks of
% X adjusted for ties.
%
% If X is a matrix, do the above for each column of X
%
% Some code from Octave 2.5.1
% Author: KH <Kurt.Hornik@ci.tuwien.ac.at>
%
% Modified 9/9/2004 by SDV for speed; assumes ties are rare.



  if (nargin ~= 1)
    error ('usage: ranks (x)');
  end

  y = [];

  [r, c] = size (x);
  if ((r == 1) & (c > 0))
    y = rankrow(x')';
  elseif (r > 1)
    for i = 1 : c;
      y = [y, rankrow(x(:,i)')'];
    end
  end

function rnk=rankrow(y)
 % assumes ties uncommon, will be slow if many ties
[s,i]=sort(y);
rnk = zeros(1,length(y));
rnk(i) = 1:length(y);
d = diff(s);
inds = [find(d==0)];
j = 1;
while j<=length(inds),
	k = 1;
	while inds(j)+k<=length(d)&d(inds(j)+k)==0, k=k+1; end;
	rnk(i(inds(j):inds(j)+k)) = rnk(i(inds(j))) + (k)/2;
	j = j+k;
end;
