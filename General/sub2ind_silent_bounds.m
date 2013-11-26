function [ndx, ind_outofbounds] = sub2ind_silent_bounds(siz,varargin)
%SUB2IND_SILENT_BOUNDS Linear index from multiple subscripts 
%   SUB2IND_SILENT_BOUNDS is used to determine the equivalent single index
%   corresponding to a given set of subscript values. It sets out of bound
%   elements to index 1
%
%   IND = SUB2IND_SILENT_BOUNDS(SIZ,I,J) returns the linear index equivalent to the
%   row and column subscripts in the arrays I and J for an matrix of
%   size SIZ. 
%
%   IND = SUB2IND_SILENT_BOUNDS(SIZ,I1,I2,...,IN) returns the linear index
%   equivalent to the N subscripts in the arrays I1,I2,...,IN for an
%   array of size SIZ.
%
%   I1,I2,...,IN must have the same size, and IND will have the same size
%   as I1,I2,...,IN. For an array A, if IND = SUB2IND_SILENT_BOUNDS(SIZE(A),I1,...,IN)),
%   then A(IND(k))=A(I1(k),...,IN(k)) for all k.
%
%   Class support for inputs I,J: 
%      float: double, single
%  
% IND_OUTOFBOUND can include multiple copies of same point
%
% Adapted from Matlab code
% 2009, Alexander Heimel
%==============================================================================

siz = double(siz);
if length(siz)<2
        error('MATLAB:sub2ind:InvalidSize',...
            'Size vector must have at least 2 elements.');
end

if length(siz) ~= nargin-1
    %Adjust input
    if length(siz)<nargin-1
        %Adjust for trailing singleton dimensions
        siz = [siz ones(1,nargin-length(siz)-1)];
    else
        %Adjust for linear indexing on last element
        siz = [siz(1:nargin-2) prod(siz(nargin-1:end))];
    end
end

%Compute linear indices
k = [1 cumprod(siz(1:end-1))];
ndx = 1;
s = size(varargin{1}); %For size comparison
ind_outofbounds=[];
for i = 1:length(siz),
    v = varargin{i};
    %%Input checking
    if ~isequal(s,size(v))
        %Verify sizes of subscripts
        error('MATLAB:sub2ind:SubscriptVectorSize',...
            'The subscripts vectors must all be of the same size.');
    end
    ind_outofbounds=[ind_outofbounds; (find( (v(:)<1) | (v(:)>siz(i))))];
    ndx = ndx + (v-1)*k(i);
end
ndx(ind_outofbounds)=1; % set pixel 1
