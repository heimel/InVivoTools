function a = getassociate(md,n)

%  GETASSOCIATE(MD,N)
%
%  A = GETASSOCIATE(MD, N)
%
%  Returns the associate(s) of the MEASUREDDATA object MD specified by the
%  indicies in N.
%
%  See also:  MEASUREDDATA, ASSOCIATE

a = md.associates(n);
