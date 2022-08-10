function zetap = zetatest_on_psth(counts,n_events,verbose)
%ZETATEST_ON_PSTH computes a surrogate ZETA based on a PSTH
%
% ZETAP = ZETATEST_ON_PSTH( COUNTS, N_EVENTS, VERBOSE)
%
%   COUNTS is a vector with the spike counts per bin
%   N_EVENTS is the original number of stimuli/trials/events
%   if VERBOSE is true a figure of the generated spikes and PSTH is shown
%
% 2022, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = false; %#ok<NASGU>
end

scurr = rng;
rng(21375); % to get reproducable results

maxp = 0;
n_samples = 10;
for sample = 1:n_samples
    
    binwidth = 0.01; % should be irrelevant
    n_bins = length(counts);
    n_spikes = sum(counts);
    duration = binwidth * n_bins;
    spiketimes = NaN(n_spikes,1);
    s = 0;
    t = 0;
    % generate spike times, collapsed to single trial
    for i=1:n_bins
        spiketimes( s + (1:counts(i)) ,1) = t + binwidth*(rand(counts(i),1));
        s = s + counts(i);
        t = t + binwidth;
    end
    % distribute the spikes over trials
    events = randi(n_events,n_spikes,1);
    eventstarts = duration*(0:(n_events-1))'; % first event starts a 0 s.
    
    spiketimes = spiketimes + eventstarts(events);
    spiketimes = sort(spiketimes);
    zetap = zetatest(spiketimes,eventstarts);
    if zetap>maxp
        maxp = zetap;
    end
end % sample
zetap = maxp;

if false
    figure('Name','PSTH-based','NumberTitle','off'); %#ok<UNRCH>
    subplot(2,1,1);
    rastergram(spiketimes,eventstarts,duration);
    xlim([0 n_bins*binwidth]);
    subplot(2,1,2);
    bar( (0.5:n_bins)*binwidth,counts);
    xlim([0 (n_bins)*binwidth]);
    title(['ZETA = ' num2str(zetap)]);
end

rng(scurr);
