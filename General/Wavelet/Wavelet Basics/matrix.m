% USAGE: M=matrix(C,T)
% FUNCTION: converts a cellular array into a matrix with centered lines 
%           and length T (optional)

function M=matrix(C,T);
nc =length(C);
ns=0;
for k=1:nc ns=max(ns,length(C{k})); end
if (nargin>1) ns=max(ns,T);end;
M=zeros(nc,ns);
for k=1:nc
   T1=length(C{k});
   C{k}=reshape(C{k},[1,T1]);
   T=floor((ns-T1)/2);
   M(k,(T+1):(T+T1))=C{k};
   end