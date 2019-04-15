function params = oxyprocessparams( record, params )
%OXYPROCESSPARAMS returns parameters for oxymeter analysis
%
%  PARAMS = OXYPROCESSPARAMS( RECORD )
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2019, Alexander Heimel

if nargin<2
    params = [];
end

params.heartrate_binwidth = 0.1; %s
params.heartrate_pre_window = [-1 0]; % time window (s) for analysis before stim
params.heartrate_post_window = [0 3]; % time window (s) for analysis after stim
params.heartrate_separation_from_prev_stim_off = 0.5;  % time (s) to stay clear of prev_stim_off
params.heartrate_max = 30; %Hz, really upper limit
params.heartrate_samplerate = 5000; % Hz

% for Savitzky-Golayfilter
params.heartrate_polyorder = 0; %
params.heartrate_windowsize = ceil(0.015 * params.heartrate_samplerate); % samples

% for detrending
params.heartrate_sigma = ceil(0.100 * params.heartrate_samplerate); % samples

% peak detection
params.heartrate_use_hilbert = false;
params.heartrate_use_zerocrossings = true;

% if not using zero crossings:
params.heartrate_minimal_height_peaks = 0.001;
params.heartrate_minimal_distance_peaks = ceil(params.heartrate_samplerate / params.heartrate_max);

params.heartrate_smoothingbeats = 5; % number of beats to use for moving median

% which trial to plot during analysis
params.plottedtrial = 2;

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end