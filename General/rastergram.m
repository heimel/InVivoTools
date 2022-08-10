function n_spikes_shown = rastergram(spiketimes,trialstarts,interval)
%RASTERGRAM makes a rastergram with spikes per trial
%
%  RASTERGRAM(SPIKETIMES, TRIALSTARTS, INTERVAL)
%
% 2021, Alexander Heimel

if nargin<3 || isempty(interval)
    interval = median(diff(trialstarts));
end

if length(interval)==1
    interval = [0 interval];
end


n_trials = length(trialstarts);
n_spikes_shown = 0;

for r = 1:n_trials 
    start = trialstarts(r) + interval(1);
    stop = start + interval(2);
    spikes = spiketimes(spiketimes>start & spiketimes<stop)-trialstarts(r); 
    
    % plot raster
    plot([spikes spikes]',...
        [(r-0.45)*ones(size(spikes)) (r+0.45)*ones(size(spikes))]','-k');
    hold on
    
    n_spikes_shown = n_spikes_shown + length(spikes);
end
set(gca,'ydir','reverse');
ylim([1-0.5,n_trials+0.5]);

