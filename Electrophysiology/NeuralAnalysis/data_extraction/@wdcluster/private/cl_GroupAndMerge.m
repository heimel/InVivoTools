function [ncls,ncsp] = cl_GroupAndMerge(sc,cls,gcsp,nv)
% [ncls,ncsp] = cl_GroupAndMerge(cls,gcsp,nv)


% first group clusters
gr = cl_group(sc,gcsp,nv);

c = 1;
% for each group merge
for i=1:length(gr)
	% merge
	idx = gr(i).clsids;
	[fcls,fcsp] = cl_merge(sc,cls(idx),gcsp(:,idx),nv);
	% index
	n = length(fcls);
	I = c:(c+n-1);c = c+n;
	% set cls & csp
	[fcls.gr] = deal(i);
	ncls(I) = fcls;
	ncsp(:,I) = fcsp;
end

% sort according to num of pnts
numpnts = zeros(1,length(ncls));
for i=1:length(ncls)
	numpnts(i) = length(ncls(i).idx);
end
[snum,sidx] = sort(-numpnts);
ncls = ncls(sidx);
ncsp = ncsp(:,sidx);
