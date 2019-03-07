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
params.heartrate_pre_window = [-2 0]; % time window (s) for analysis before stim
params.heartrate_post_window = [0 3]; % time window (s) for analysis after stim
params.heartrate_separation_from_prev_stim_off = 0.5;  % time (s) to stay clear of prev_stim_off


params.max_heart_rate = 30; %Hz, really upper limit
params.sample_rate = 5000; % Hz 

% for Savitzky-Golayfilter
params.poly_order = 0; %
params.window_size = 71; % samples

% for detrending
params.sigma = ceil(0.14 * params.sample_rate); % samples
params.factor = 1; %

params.beats = 5; % number of beats to use for moving median



if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end