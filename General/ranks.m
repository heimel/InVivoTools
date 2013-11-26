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
% [From Octave 2.5.1]
% Author: KH <Kurt.Hornik@ci.tuwien.ac.at>
% Description: Compute ranks
% This code is rather ugly, but is there an easy way to get the ranks
% adjusted for ties from sort?



  if (nargin ~= 1)
    error ('usage: ranks (x)');
  end

  y = [];

  [r, c] = size (x);
  if ((r == 1) & (c > 0))
    p = x' * ones (1, c);
    y = sum (p < p') + (sum (p == p') + 1) / 2;
  elseif (r > 1)
    o = ones (1, r);
    for i = 1 : c;
      p = x (:, i) * o;
      y = [y, (sum (p < p') + (sum (p == p') + 1) / 2)'];
    end
  end


