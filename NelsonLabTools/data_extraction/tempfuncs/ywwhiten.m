function [b,a] = ywwhiten(C, varargin)
% ywwhiten -- compute a whitening filter using a Yule-Walker AR(p) model.
%
%	[B, A] = YWWHITEN(C) returns a filter that whitens a process
%	whose auto-covariance series is given by C.  C(i) contains the
%	(i-1)th lag.  YWWHITEN uses the Yule-Walker equations to infer
%	the AR(p) parameters that describe the process and then
%	returns the forward prediction-error filter.  By default, the
%	order, p, is one less than the length of the auto-covariance
%	series.
%
%	If C is a matrix, each column is taken to be the
%	auto-covariance of a different process and all the filters
%	are returned in the columns of B (A is always zero).
%
%	OPTIONS:
%	'order'		- order of the AR process to fit.  If greater
%			  than length(C)-1 the auto-covariance is
%			  padded with zeros. 

usage = char([9 'YWWHITEN(C, options...)' 10 ...
	      9 'options: order']);

% Copyright 1997, California Institute of Technology.
%	    written by Maneesh Sahani (maneesh@caltech.edu)
% See Percival & Walden sections 9.3 (p393) and 9.10 (p437)

if (size(C,1) == 1)			% if a row vector, transpose.
  C = C';
end

order = size(C,1) - 1;
%assign(varargin{:});

g = zeros(order, 1);
G = zeros(order, order);

n = min(order, size(C,1) -1 );

b = zeros(order+1, size(C,2));
for i = 1:size(C,2)
  g(1:n) = C(2:n+1, i);
  G(1:n, 1:n) = toeplitz(C(1:n, i));
  A = inv(G)*g;

  b(:, i) = [1; -A];
end



a = zeros(size(b));
