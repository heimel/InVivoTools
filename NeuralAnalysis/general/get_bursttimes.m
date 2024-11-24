function [bursttimes, tonictimes, n_events, params] = get_bursttimes( spiketimes, params )
%GET_BURSTTIMES returns all times of bursts from an array of spiketimes
% 
%    [BURSTTIMES, TONICTIMES, N_EVENTS, PARAMS]=GET_BURSTTIMES( SPIKETIMES, [PARAMS] )
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
%    TONICTIMES is a vector containing all times of spikes not part of a
%    burst.
%    PARAMS is a structure with the set of parameters used to
%    define bursts.
%
%    Example
%    [bursttimes,n_events,tonictimes] = get_bursttimes([0.001 0.002 0.003 0.004 1.01 1.5 2.02 2.022 2.023])
%     returns, bursttimes = [0.001 2.02]; n_events = 4; tonictime = [1.01 1.5]
%   
%    To get default settings for parameters, call GET_BURSTTIMES([]).
%  
% 2003-2024, Alexander Heimel 
%
  
if nargin<2 || isempty(params) % set default parameters
  params.max_isi = 0.008; % s
end

bursttimes = [];
n_events = 0;

if length(spiketimes)<2 
  return;  % returns params, if one wants to know default parameters
end

% select all ISIs < PARAMS.MAX_ISI
isis = diff( spiketimes );
ind_short_isis = find(isis<params.max_isi);

% n_events is total number of events where bursts and tonic spikes all
% count for one. 
n_events = length(spiketimes)-length(ind_short_isis);

if isempty(ind_short_isis)
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
