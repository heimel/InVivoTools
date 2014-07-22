function params = ecprocessparams( record )
%ECPROCESSPARAMS parameters for ec and lfp analysis
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2012-2014, Alexander Heimel
%

if nargin<1
    record = [];
end
if isempty(record)
    record.mouse = '00.00.0.00';
    record.setup = 'nin380';
end

if length(record.mouse)>5 && length(find(record.mouse=='.'))>1
    protocol = record.mouse(1:5);
else
    protocol = '';
end

% defaults
params.pre_window = [-Inf 0]; % ignored for ec and tp
params.post_window = [0 Inf]; % ignored for tp
params.separation_from_prev_stim_off = 0.5;  % time (s) to stay clear of prev_stim_off
%params.early_response_window = [0.05 0.2];  % not implemented yet
%params.late_response_window = [0.5 inf]; % not implemented yet

switch protocol
    case '11.35'
        params.pre_window = [-inf 0];
        params.post_window = [0 inf];
    case '13.20'
        % params.pre_window = [-Inf 0];
        % params.post_window = [0 inf];
        % params.separation_from_prev_stim_off = 5;
end

% sg parameters
% after 0.4 s there is generally little response
% I realize that 0.4 s already includes 2 frames if run at 5 Hz
% 20ms taken as lead time for first responses to appear
params.rc_interval=[0.0205 0.4205];
params.rc_timeres=0.2;
switch protocol
    case '13.20' 
        params.rc_interval=[0.0205 0.2205];
end

params.vep_poweranalysis_type = 'wavelet'; % or 'periodogram' or 'wavelet'

params.vep_remove_line_noise = 'temporal_domain'; % 'frequency_domain' or 'none' or 'temporal_domain'

params.vep_remove_vep_mean = true; % removes average VEP response before power analysis

params.vep_log10_freqs = true;

params.cell_colors = repmat('kbgrcmy',1,50);

% spike isolation
params.max_spike_clusters = 2;
params.cluster_overlap_threshold = 0.5;

% entropy analysis
switch record.mouse(1:min(end,5))
    case '12.28'
        params.entropy_analysis = false;
    otherwise
        params.entropy_analysis = false;
end

switch lower(record.setup)
    case {'antigua','daneel','nin380'}
        params.spike_sorting_routine = '';
        params.compare_with_klustakwik = false;
    otherwise
        switch record.mouse(1:min(end,5))
            case {'05.01','07.30'}
                params.spike_sorting_routine = '';
                params.compare_with_klustakwik = false;
            case {'13.20'}
                params.spike_sorting_routine = 'klustakwik';
                params.compare_with_klustakwik = true;
            case {'11.35'}
                params.spike_sorting_routine = '';
                params.compare_with_klustakwik = true;
            otherwise
                params.spike_sorting_routine = '';
                params.compare_with_klustakwik = true;
        end
end

% time calibration
switch lower(record.setup)
    case 'antigua' 
        params.trial_ttl_delay = 0.00; % s delay of visual stimulus after trial start TTL
        params.secondsmultiplier = 1.000017000; % multiplification factor of electrophysical signal time
    otherwise
        warning('ECPROCESSPARAMS:TIMING','ECPROCESSPARAMS: Setup not time calibrated yet');
        warning('off', 'ECPROCESSPARAMS:TIMING');
end

params.compute_fraction_overlapping_spikes = false;
switch experiment
    case '13.20'
        params.compute_fraction_overlapping_spikes = true;
end

if exist('processparams_local.m','file')
    params = processparams_local( params );
end
    