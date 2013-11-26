function [bursttimes, n_events, params]=get_bursttimes( spiketimes, params )
%GET_BURSTTIMES returns all times of bursts from an array of spiketimes
% 
%    [BURSTTIMES, N_EVENTS, PARAMS]=GET_BURSTTIMES( SPIKETIMES )
%    [BURSTTIMES, N_EVENTS, PARAMS]=GET_BURSTTIMES( SPIKETIMES, PARAMS )
% 
%    SPIKETIMES is a vector containing all spiketimes. PARAMS is a
%    structure with fields used as parameters for defining bursts.
%    Currently, it only has one field PARAMS.MAX_ISI.
%    Any two spikes within an interval of PARAMS.MAX_ISI are considered to 
%    be part of the same burst. PARAMS.MAX_ISI should have same time unit
%    as SPIKETIMES. 
%
%    BURSTTIMES is a vector containing all times of the first spikes of a 
%    butst. N_EVENTS is the total number of events, both bursts (which
%    are counted once, even if they include multiple spikes) and tonic
%    spikes. PARAMS is a structure with the set of parameters used to
%    define bursts.
%
%    To get default settings for parameters, call GET_BURSTTIMES([]).
%  
% 2003, Alexander Heimel (heimel@brandeis.edu)
%
  
if nargin<2 % set default parameters
  params=[];
end

if isempty(params)
  params.max_isi=0.008; % s, 
end

bursttimes=[];
n_events=0;

if length(spiketimes)<2 
  return;  % returns params, if one wants to know default parameters
end

% select all ISIs < PARAMS.MAX_ISI
isis=diff( spiketimes );
ind_short_isis=find(isis<params.max_isi);

% n_events is total number of events where bursts and tonic spikes all
% count for one. 
n_events=length(spiketimes)-length(ind_short_isis);


if isempty(ind_short_isis)
  return
end

%now only select first spike of each burst
ind_first_spikes=[1 find( diff( ind_short_isis)> 1)+1];
bursttimes=spiketimes( ind_short_isis( ind_first_spikes) ) ;
