function s = ivt_sem(x,dim)
% ivt_sem. Returns STD / SQRT #X
%
%  S = ivt_sem(X,DIM=1)
%
% 200X-2026, Alexander Heimel
%

if isempty(x)
    s = [];
    return
end

if nargin==1
  s = nanstd(x)./sqrt(sum(~isnan(x)));
else  
  s = std(x,0,dim)/sqrt(size(x,dim));
end

