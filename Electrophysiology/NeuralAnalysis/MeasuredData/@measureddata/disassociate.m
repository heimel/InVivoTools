function nmd = disassociate(md,n)

%  NEWMD = DISASSOCIATE(MD,N)
%
%  Disassociates the associate(s) specified by indicies N from the MEASUREDDATA
%  object MD.  A new object is returned in NEWMD.

l = 1:numassociates(md); for i=1:length(n),l=l(find(l~=n(i)));end;

md.associates = md.associates(l);
nmd = md;
