function [n_spikes_shown,rel_spiketimes] = rastergram(spiketimes,trialstarts,interval,options)
%RASTERGRAM makes a rastergram with spikes per trial
%
%  RASTERGRAM(SPIKETIMES, TRIALSTARTS, INTERVAL, Color=[1 1 1])
%
%     INTERVAL can be double with max. time to show after trial start
%           or 2-vector with start and end time relatieve to trial start,
%           e.g. [-0.5 2]
%
% 2021-2025, Alexander Heimel

arguments
    spiketimes
    trialstarts
    interval
    options.Color = [0 0 0]
end

if nargin<3 || isempty(interval)
    interval = median(diff(trialstarts));
end

if length(interval)==1
    interval = [0 interval];
end

if nargout>1
    rel_spiketimes = NaN(size(spiketimes));
end

n_trials = length(trialstarts);
n_spikes_shown = 0;

ylim([1-0.5,n_trials+0.5]);
hold on
plot([0 0],ylim,'color',[0.8 0.8 1])

for r = 1:n_trials 
    start = trialstarts(r) + interval(1);
    stop = trialstarts(r) + interval(2);
    spikes = spiketimes(spiketimes>start & spiketimes<stop)-trialstarts(r); 
    
    if nargout>1
        rel_spiketimes(n_spikes_shown+1:n_spikes_shown+length(spikes))  = spikes;
    end

    % plot raster
    plot([spikes spikes]',...
        [(r-0.45)*ones(size(spikes)) (r+0.45)*ones(size(spikes))]','-','Color',options.Color);
    hold on
    
    n_spikes_shown = n_spikes_shown + length(spikes);
end
set(gca,'ydir','reverse');

xlim(interval);

if nargout>1
    rel_spiketimes(n_spikes_shown+1:end) = [];
end