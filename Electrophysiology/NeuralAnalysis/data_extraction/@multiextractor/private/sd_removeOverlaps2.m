function [y,id] = sd_removeOverlaps2(est,type)

id = find(type~=7);
y = est(id);

% identifies overlaps by type==7 criteria _and_ no spikes within len samples
% criteria--since len is 5.5ms, this is no good for in vivo.
% 
%d = diff(est);
%di = find(d < gsd.len);
%dii = di+1;

%id = 1:1:length(est);
%id = setdiff(id, di);
%id = setdiff(id, dii);

%it = find(type == 7);	% overlapped
%id = setdiff(id,it);	% remove them

%id = reshape(id, length(id),1);
%y = est(id);


