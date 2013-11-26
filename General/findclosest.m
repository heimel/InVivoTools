function [i,nv] = findclosest(arr,v)

% FINDCLOSEST
%
% [I,V] = FINDCLOSEST(ARRAY,VALUE)
%
% Finds the index to the closest member of ARRAY to VALUE
% in absolute value. It returns the index in I and the value
% in V.  If ARRAY is empty, so are I and V.
%
% If there are multiple occurances of VALUE within ARRAY,
% only the first is returned in I.
%
% See also: FIND

if isempty(arr), 
  i = []; 
  nv = []; 
  return
end;
nv=nan*ones(size(v));
i=nan*ones(size(v));
for j=1:length(v(:))
  [tmp,i(j)]=min(abs(arr-v(j)));
  nv(j) = arr(i(j));
end

