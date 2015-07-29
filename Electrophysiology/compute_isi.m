function isis = compute_isi( times1,times2, max_spikes,max_interval)
%COMPUTE_ISI compute isis between to spike trains
%
% ISIS = COMPUTE_ISI( TIMES1, TIMES2, MAX_SPIKES, MAX_INTERVAL )
%
% Memory intensive and slow. Should be rewritten
%
% 2015, Alexander Heimel
%

if nargin<3 || isempty(max_spikes)
    max_spikes = 2000;
end

if nargin<4 || isempty(max_interval)
    max_interval = 0.05;
end

spikes1 = repmat( times1(1:min(end,max_spikes))',...
    length(times2(1:min(end,max_spikes))),1);
spikes2 = repmat( times2(1:min(end,max_spikes)),...
    1,length(times1(1:min(end,max_spikes))));
intervals = flatten(spikes2-spikes1);
intervals(intervals==0) = [];
isis = intervals(abs(intervals)<max_interval);

    
    
    