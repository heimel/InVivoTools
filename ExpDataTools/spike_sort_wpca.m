function [IDX,NumClust] = spike_sort_wpca(cll1,record,verbose)
%
%
% 2013-2015, Mehran Ahmadlou, Alexander Heimel
%

if nargin<3 
    record = [];
end

params = ecprocessparams(record);

NumClust = params.max_spike_clusters;

if nargin<4 || isempty(verbose)
    verbose = 0;
end

if length(cll1(1).data)<10% cant sort with less than 10 spikes
    logmsg('Fewer than 10 spikes. Not sorting channel');
    NumClust = 1;
end

if NumClust == 1
    IDX = ones(size(cll1.data));
    return
end

range_peak_trough_ratio = range(cll1.spike_peak_trough_ratio);
if range_peak_trough_ratio==0
    range_peak_trough_ratio = 1;
end
range_prepeak_trough_ratio = range(cll1.spike_prepeak_trough_ratio);
if range_prepeak_trough_ratio==0
    range_prepeak_trough_ratio = 1;
end
range_trough2peak_time = range(cll1.spike_trough2peak_time);
if range_trough2peak_time == 0 
    range_trough2peak_time = 1;
end
range_spike_lateslope = range(cll1.spike_lateslope);
if range_spike_lateslope == 0 
    range_spike_lateslope = 1;
end

XX=[cll1.spike_peak_height,cll1.spike_trough_depth,... 
    cll1.spike_amplitude,... 
    cll1.spike_lateslope/range_spike_lateslope,...
    cll1.spike_prepeak_trough_ratio/range_prepeak_trough_ratio,...
    cll1.spike_trough2peak_time/range_trough2peak_time,...
    cll1.spike_peak_trough_ratio/range_peak_trough_ratio,...
    cll1.spike_lateslope];

[pc,score,latent,tsquare] = princomp(XX);

[IDX,f1,f2,D] = kmeans(score(:,1:3),NumClust);

return

