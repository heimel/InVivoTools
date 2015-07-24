function params = ecprocessparams( record )
%ECPROCESSPARAMS parameters for ec and lfp analysis
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2012-2015, Alexander Heimel
%

if nargin<1 || isempty(record)
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
params.minimum_spontaneous_time = 0.5; % need at least this period for spontaneous activity
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

params.compute_f1f0 = false;

% reverse correlation (sg) parameters
% after 0.4 s there is generally little response
% I realize that 0.4 s already includes 2 frames if run at 5 Hz
% 20ms taken as lead time for first responses to appear
params.rc_interval = [0.0205 0.4205];
params.rc_timeres = 0.2; % time resolution
% params.rc_peak_interval_number = 1; % which interval to use for peak computation
switch protocol
    case '13.20'
        params.rc_interval=[0.0205 0.2205];
end

params.vep_poweranalysis_type = 'wavelet'; % or 'spectrogram' or 'wavelet'
params.vep_remove_line_noise = 'temporal_domain'; % 'frequency_domain' or 'none' or 'temporal_domain'
params.vep_remove_vep_mean = true; % removes average VEP response before power analysis
params.vep_log10_freqs = true;
params.vep_wavelet_freq_high = 100;
params.vep_wavelet_freq_low = 1;
params.vep_wavelet_freq_res = params.vep_wavelet_freq_high; % reduce this to increase speed
params.vep_wavelet_alpha = 3; % was 1
params.vep_wavelet_beta = 1; % was 3

params.cell_colors = repmat('kbgrcmy',1,50);

% spike isolation
params.max_spike_clusters = 4;
params.cluster_overlap_threshold = 0.5;


params.show_isi = false;

params.plot_spike_features = false;

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
                params.compare_with_klustakwik = false;
        end
end
switch lower(record.setup)
    case 'antigua'
        params.sort_trigger_ind = 8;
    otherwise
        params.sort_trigger_ind = 8; % should be changed[];
end
params.sort_always_resort = false;
params.sort_compute_cluster_overlap = false;
params.sort_klustakwik_arguments = [ ...
    ' -ElecNo 1' ...
    ' -nStarts 1' ...
    ' -MinClusters 1' ...   % 20
    ' -MaxClusters ' num2str(params.max_spike_clusters) ...   % 30
    ' -MaxPossibleClusters ' num2str(params.max_spike_clusters) ...  % 100
    ' -UseDistributional 0' ...
    ' -PriorPoint 1'...
    ' -FullStepEvery 20'... %
    ' -UseFeatures  1010100' ... %10101  %10111 11111
    ' -SplitEvery 40' ...
    ' -RandomSeed 1' ...
    ' -MaxIter 500' ...  % 500
    ' -DistThresh 6.9' ...   % 6.9
    ' -ChangedThresh 0.05' ... % 0.05
    ' -PenaltyK 0'... % 0
    ' -PenaltyKLogN 1' ]; % 1

%             ' -UseMaskedInitialConditions 1'...  % 1
%         ' -AssignToFirstClosestMask 1'...


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
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end
