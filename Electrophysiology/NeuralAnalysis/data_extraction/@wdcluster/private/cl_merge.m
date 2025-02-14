function [fcls,fcsp] = cl_merge(sc,grcls,grcsp,nv)
% [fcls,fcsp] = cl_merge(gcls,gcsp,nv)
% grcls: group cls'
% grcsp: group csp

num = length(grcls);
[fcls,fcsp] = cl_mergeOne(sc,grcls,grcsp,nv);

while length(fcls) < num
	num = length(fcls);
	[fcls,fcsp] = cl_mergeOne(sc,fcls,fcsp,nv);
end
