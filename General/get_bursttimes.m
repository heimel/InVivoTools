function [bursttimes, tonictimes, n_events, spikes_per_burst, mean_burst_isi, params] = get_bursttimes( spiketimes, params )
%GET_BURSTTIMES returns all times of bursts from an array of spiketimes
% 
%    [BURSTTIMES, TONICTIMES, N_EVENTS, SPIKES_PER_BURST, MEAN_BURST_ISI, PARAMS] = 
%              GET_BURSTTIMES( SPIKETIMES, [PARAMS] )
% 
%    SPIKETIMES is a vector containing all spiketimes. PARAMS is a
%    structure with fields used as parameters for defining bursts.
%    Currently, it only has one field PARAMS.MAX_ISI.
%    Any two spikes within an interval of PARAMS.MAX_ISI are considered to 
%    be part of the same burst. PARAMS.MAX_ISI should have same time unit
%    as SPIKETIMES. 
%
%    BURSTTIMES is a vector containing all times of the first spikes of a 
%    burst. 
%    N_EVENTS is the total number of events, both bursts (which
%    are counted once, even if they include multiple spikes) and tonic
%    spikes.
%    MEAN_SPIKES_PER_BURST is the mean number of spikes per burst
%    MEAN_BURST_ISI is the mean ISI within all bursts
%    PARAMS is a structure with the set of parameters used to
%    define bursts.
%
%    Example
%    [bursttimes,n_events,tonictimes] = get_bursttimes([0.001 0.002 0.003 0.004 1.01 1.5 2.02 2.022 2.023])
%     returns, bursttimes = [0.001 2.02]; n_events = 4; tonictime = [1.01 1.5]
%   
%    To get default settings for parameters, call GET_BURSTTIMES([]).
%  
% 2003-2025, Alexander Heimel 
%
  
if nargin<2 || isempty(params) % set default parameters
  params.max_isi = 0.008; % s
end

bursttimes = [];
tonictimes = [];
n_events = 0;
spikes_per_burst = NaN;
mean_burst_isi = NaN;

if length(spiketimes)<2 
  return;  % returns params, if one wants to know default parameters
end

% select all ISIs < PARAMS.MAX_ISI
isis = diff( spiketimes );
ind_short_isis = find(isis<params.max_isi);

mean_burst_isi = mean(isis(ind_short_isis)); % of course dependent on max_isi

% n_events is total number of events where bursts and tonic spikes all
% count for one. 
n_events = length(spiketimes)-length(ind_short_isis);

if isempty(ind_short_isis)
    tonictimes = spiketimes;
  return
end

ind_later_burst_spikes = ind_short_isis+1;
ind_first_burst_spikes = setdiff(ind_short_isis,ind_short_isis+1);

ind_all = 1:length(spiketimes);
if size(spiketimes,1)>1 % column vector
    ind_all = ind_all';
end

ind_tonic_spikes = setdiff(ind_all,union(ind_first_burst_spikes,ind_later_burst_spikes));

bursttimes = spiketimes( ind_first_burst_spikes ) ;
tonictimes = spiketimes( ind_tonic_spikes ) ;


n_bursts = length(bursttimes);
spikes_per_burst = NaN(1,n_bursts);
for i = 1:n_bursts
    ind_first = ind_first_burst_spikes(i);
    if i<n_bursts
        ind_next_burst = ind_first_burst_spikes(i+1);
    else
        ind_next_burst = length(spiketimes)+1;
    end
    spikes_per_burst(i) = 1 + ...
        length(find(ind_later_burst_spikes>ind_first & ind_later_burst_spikes<ind_next_burst));
end % i
