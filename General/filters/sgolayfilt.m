function y=sgolayfilt(x,order,framelen,weights,dim)
%SGOLAYFILT Savitzky-Golay Filtering.
%   SGOLAYFILT(X,ORDER,FRAMELEN) smoothes the signal X using a
%   Savitzky-Golay (polynomial) smoothing filter.  The polynomial order,
%   ORDER, must be less than the frame length, FRAMELEN, and FRAMELEN must
%   be odd.  The length of the input X must be >= FRAMELEN.  If X is a
%   matrix, the filtering is done on the columns of X.
%
%   Note that if the polynomial order ORDER equals FRAMELEN-1, no smoothing
%   will occur.
%
%   SGOLAYFILT(X,ORDER,FRAMELEN,WEIGHTS) specifies a weighting vector
%   WEIGHTS with length FRAMELEN containing real, positive valued weights
%   employed during the least-squares minimization. If not specified, or if
%   specified as empty, WEIGHTS defaults to an identity matrix.
%
%   SGOLAYFILT(X,ORDER,FRAMELEN,[],DIM) and
%   SGOLAYFILT(X,ORDER,FRAMELEN,WEIGHTS,DIM) operate along the dimension DIM.
%
%   % Example:
%   %   Smooth the mtlb signal by applying a cubic Savitzky-Golay filter 
%   %   to data frames of length 41.
%   load mtlb                        % Load data
%   smtlb = sgolayfilt(mtlb,3,41);   % Apply 3rd-order filter
%   plot([mtlb smtlb]);
%   legend('Original Data','Filtered Data');
%
%   See also SGOLAY, MEDFILT1, FILTER

%   References:
%     [1] Sophocles J. Orfanidis, INTRODUCTION TO SIGNAL PROCESSING,
%              Prentice-Hall, 1995, Chapter 8.

%   Author(s): R. Losada
%   Copyright 1988-2016 The MathWorks, Inc.
%
% 2019, Adapted

narginchk(3,5);

% Check if the input arguments are valid
if round(framelen) ~= framelen, error(message('signal:sgolayfilt:MustBeIntegerFrameLength')), end
if rem(framelen,2) ~= 1, error(message('signal:sgolayfilt:SignalErr')), end
if round(order) ~= order, error(message('signal:sgolayfilt:MustBeIntegerPolyDegree')), end
if order > framelen-1, error(message('signal:sgolayfilt:InvalidRangeDegree')), end

if nargin < 4
   weights = [];
elseif ~isempty(weights)
   % Check for right length of WEIGHTS
   if length(weights) ~= framelen, error(message('signal:sgolayfilt:InvalidDimensionsWeight')),end
   % Check to see if all elements are positive
   if min(weights) <= 0, error(message('signal:sgolayfilt:InvalidRangeWeight')), end
end

if nargin < 5, dim = []; end

% Check the input data type. Single precision is not supported.
% chkinputdatatype(x,order,framelen,weights,dim);

% Compute the projection matrix B
B = sgolay(order,framelen,weights);

if ~isempty(dim) && dim > ndims(x)
	error(message('signal:sgolayfilt:InvalidDimensionsInput', 'X'))
end

% Reshape X into the right dimension.
if isempty(dim)
	% Work along the first non-singleton dimension
	[x, nshifts] = shiftdim(x);
else
	% Put DIM in the first dimension (this matches the order 
	% that the built-in filter function uses)
	perm = [dim,1:dim-1,dim+1:ndims(x)];
	x = permute(x,perm);
end

if size(x,1) < framelen, error(message('signal:sgolayfilt:InvalidDimensionsTooSmall')), end

% Compute the transient on
ybegin = B(end:-1:(framelen-1)/2+2,:) * x(framelen:-1:1,:);

% Compute the steady state output
ycenter = filter(B((framelen-1)./2+1,:), 1, x);

% Compute the transient off
yend = B((framelen-1)/2:-1:1,:) * x(end:-1:end-(framelen-1),:);

% Concatenate
y = [ybegin; ycenter(framelen:end,:); yend];

% Convert Y to the original shape of X
if isempty(dim)
	y = shiftdim(y, -nshifts);
else
	y = ipermute(y,perm);
end

