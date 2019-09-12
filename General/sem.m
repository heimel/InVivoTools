function s=sem(x,dim)
%SEM returns STD / SQRT #X
%
%  S = SEM(X,DIM)
%
% Alexander Heimel?
%

if isempty(x)
    s = [];
    return
end

if nargin==1
  s=nanstd(x)./sqrt(sum(~isnan(x)));
else  
  s=std(x,0,dim)/sqrt(size(x,dim));
end

