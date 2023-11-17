function y = nansem(x,dim)
%nansem. Standard error of the mean, ignoring NaNs.
%   Y = nansem(X,dim)
%
% 200X-2023, Alexander Heimel

if nargin<2 || isempty(dim)
    if size(x,1)==1
        dim = ndims(x);
    else
        dim = 1;
    end
end

n = sum(~isnan(x),dim);
y = nanstd(x,[],dim)./sqrt(n);
end
