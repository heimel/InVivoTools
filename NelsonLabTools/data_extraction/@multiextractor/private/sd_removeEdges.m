function [y,id] = sd_removeEdges( me, est, idx, dt )
% y = removeEdge(est)
% replen: length of one rep
% est: ex spike times
% dt: time between samples

replen = fix(10/dt);

pre = ceil(me.MEparams.pre_time/dt);
post = ceil(me.MEparams.post_time/dt);

i = find(((est-pre)>0)&((est+post)<replen));
y = est(i);
id = idx(i);

% start
%sti=1;
%while (est(sti) - pre) < 1 
%	sti = sti + 1;
%end
		
% end
%edi=length(est);
%while (est(edi) + post) > replen
%	edi = edi - 1;
%end
%
%y = est(sti:edi);
%id = idx(sti:edi);
