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
params.ec_axon_default_filename = 'data.abf'; 
params.ec_binwidth = 0.01; % binwidth in s for tuning_curve in analyse_ps
params.pre_window = [-Inf 0]; % ignored for ec and tp
params.post_window = [0 Inf]; % ignored for tp
params.separation_from_prev_stim_off = 0.5;  % time (s) to stay clear of prev_stim_off
params.minimum_spontaneous_time = 0.5; % need at least this period for spontaneous activity
%params.early_response_window = [0.05 0.2];  % not implemented yet
%params.late_response_window = [0.5 inf]; % not implemented yet
params.ec_temporary_timeshift = 0; % to induce a timeshift for analysis
params.results_show_psth_count_all = false;
params.ec_compute_spikerate_adaptation = false;

params.always_use_matlab_tdt = false;

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
params.rc_gain = 1; % image gain
params.rc_interactive = false; % interactive reverse correlation figures
% params.rc_peak_interval_number = 1; % which interval to use for peak computation

%switch protocol
%    case '13.20'
%        params.rc_interval=[0.0205 0.2205];
%    case '13.03'
%        params.rc_interval=[0.0205 0.6205];
%end

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

params.compute_isi = false;
params.show_isi = false;

params.plot_spike_features = true;
params.plot_spike_shapes = true;
params.plot_spike_shapes_max_spikes = 500;


% entropy analysis
switch record.mouse(1:min(end,5))
    case '12.28'
        params.entropy_analysis = false;
    otherwise
        params.entropy_analysis = false;
end

params.ec_spike_smoothing = ''; % '', 'wavelet', or 'sgolay' 

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
    case 'antigua' % tdt data on nin380
        newsetupdate = '2018-01-01';
        if datenum(record.date)>=datenum(newsetupdate)
          params.trial_ttl_delay = -0.009; % s delay of visual stimulus after trial start TTL
          params.secondsmultiplier = 0.9999986; % multiplification factor of electrophysical signal time 
        else    
          params.trial_ttl_delay = 0.00; % s delay of visual stimulus after trial start TTL
          params.secondsmultiplier = 1.000017000; % multiplification factor of electrophysical signal time 
        % calibrated on 4-2-2016 (experiment 14.14), should be 1.0000190, but kept at 1.000017
        % to not change previous analysis
        end
    case 'intan' % 
        params.trial_ttl_delay = -0.01; % s delay of visual stimulus after trial start TTL
        params.secondsmultiplier = 0.999981; % aligned on 2018-06-15
    case 'wall-e'
        params.trial_ttl_delay = 0.00; % s delay of visual stimulus after trial start TTL
        params.secondsmultiplier = 1; % multiplification factor of electrophysical signal time
        warning('ECPROCESSPARAMS:TIMING','ECPROCESSPARAMS: Setup not time calibrated yet');
        warning('off', 'ECPROCESSPARAMS:TIMING');
    case 'daneel'
        params.trial_ttl_delay = 0.0115;
        params.secondsmultiplier = 1.000032; % aligned on 2012-09-18
    case 'nin380' % spike2 data on nin380
        params.trial_ttl_delay = 0.00; % s delay of visual stimulus after trial start TTL
        params.secondsmultiplier = 1; % multiplification factor of electrophysical signal time
        warning('ECPROCESSPARAMS:TIMING','ECPROCESSPARAMS: Setup not time calibrated yet');
        warning('off', 'ECPROCESSPARAMS:TIMING');
    otherwise
        warning('ECPROCESSPARAMS:TIMING','ECPROCESSPARAMS: Setup not time calibrated yet');
        warning('off', 'ECPROCESSPARAMS:TIMING');
end

params.ec_intan_spikethreshold = -50; % threshold of spike detection
params.ec_apply_notchfilter = true; % only implemented for importintan
params.ec_rereference = 'remove_first_pc'; % currently only implemented for intan
params.ec_show_spikedetection = true; % only implemented for importintan
params.compute_fraction_overlapping_spikes = false;

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end
