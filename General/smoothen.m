function y = smoothen(x,sigma)
%SMOOTHEN convolves vector with gaussian
%
%   Y = SMOOTHEN(X,[SIGMA=1])
%        X can be 1D or 2D
%
%  2004-2024, Alexander Heimel

if nargin<2 || isempty(sigma)
    sigma = 1;
end
if isnan(sigma) || sigma==0
    y = x;
    return
end

cutoff = ceil(3*sigma);

if numel(x)==length(x) % 1D
    gauss = (-cutoff:cutoff);
    if sigma>0
        gauss = exp(- gauss.^2/2/sigma^2);
    else
        gauss = 1;
    end
    
    gauss = gauss/sum(gauss);
    
    y = conv(x,gauss);
    y = y(cutoff+1:end-cutoff);
    return
end

% else 2D


gauss=gaussian([2*cutoff+1 2*cutoff+1],...
    [cutoff+1,cutoff+1],...
    sigma);

% normalize:
gauss=gauss/sum(gauss(:));

y=conv2(x,gauss,'same');
