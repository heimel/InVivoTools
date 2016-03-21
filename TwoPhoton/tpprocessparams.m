function params = tpprocessparams(  record )
%TPPROCESSPARAMS returns default two-photon calcium data processing parameters
%
% PARAMS = TPPROCESSPARAMS( RECORD)
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2009-2015, Alexander Heimel
%

if nargin<1
    record.setup = 'olympus-0603301';
    record.datatype = 'tp';
    record.experiment = '10.38'; % fairly arbitrary calcium imaging protocol
end

switch record.datatype
    case 'ls' % linescans
        params.method ='event_detection';
    otherwise
        params.method = 'none';
end

switch params.method
    case 'none'
        params.detrend = false;
        params.artefact_removal = false;
        params.normalize = false;
        params.detect_events = false;
    case 'normalize'
        params.detrend = true;
        params.artefact_removal = true;
        params.normalize = true;
        params.detect_events = false;
    case 'event_detection'
        params.detrend = true;
        params.artefact_removal = true;
        params.normalize = true;
        params.detect_events = true;
        params.detect_events_group = true;
end

params.normalize_baseline_method = 'prctile'; % mean 
params.normalize_prctile = 5; 

switch record.datatype
    case 'ls' % friederike
        params.clip_data = true; %
        params.artefact_removal = true;
    otherwise
        params.clip_data = false; %
        params.artefact_removal = false;
end

% temporal filter settings
params.filter.type = 'smooth';  % {'smooth','none'}
params.filter.parameters = 0;
params.filter.unit = '#'; % {'#','s'}

% artefact removal
params.artefact_diplevel = 2; % in std
params.artefact_minimal_samplenumber = 30; % minimum number of samples for an interval

% peak removal for mean and std calculation
params.peak_removal_percentile = 95; % in percent
params.peak_removal_width = 0.3; % time (s)

% data clipping
params.clip_data_max_gap = 5; % maximum time gap in seconds

% event detection
params.detect_events_threshold = 2;% (std)
params.detect_events_minpeakdistance = 2;% (seconds) minimum distance between two peaks
params.detect_events_max_time_before_peak = 4;% seconds to include in event before peak
params.detect_events_max_time_after_peak = 4;% seconds to include in event after peak
params.detect_events_margin = 0;%  (seconds) margin to find minimum and half maximum for peak interval
params.detect_events_fit_slope = true; % use the derivative of the signal to fit onset time
params.detect_events_group = true;
params.detect_events_group_width = 0.4;% (seconds) minimum interval between two global events
params.detect_events_group_minimum_cell_number = 0.1; % if smaller than 1, then it is interpreted as fraction
params.detect_events_time = 'peak';
params.detect_events_fit_slope = false;
params.findpeaks_fast = false; % use findpeaks fast

switch record.experiment
    case '12.98' % Rogier
       params.detect_events_threshold = 2.5;% (std) 
end

% wave detection
params.wave_criterium = -1.163; % z-scores below which events are considered waves
                                % with z<-1.163, only 1 in 10 is false positive
params.wave_zscore_shuffles = 100;%;
params.wave_aspect_ratio_correction = false;%true;

% event type classification
params.retinal_event_threshold = 0.2; % minimal participating fraction
params.cortical_event_threshold = 0.8; % minimal participating fraction

% output settings 
params.output_show_figures = true;
params.output_show_waves = true;

% image processing (for z-stack)
switch lower(record.experiment)
    case 'holtmaat'
        params.unmixing = false; % channel unmixing
        params.spatial_filter = false;
    case {'10.24','11.12'}
        params.unmixing = true; % channel unmixing
        params.spatial_filter = true;
    case {'11.74'}
        params.unmixing = true; % channel unmixing
        params.spatial_filter = true;
    otherwise
        params.unmixing = false; % channel unmixing
        params.spatial_filter = false;
end

% unmixing parameters

params.unmixing_use_pixels = 'highchan2'; % used since 2012-01-30
%params.unmixing_use_pixels = 'topchan2'; % used since 2011-08-11
% params.unmixing_use_pixels = 'mean'; % used before 2011-08-11
% params.unmixing_use_pixels = 'all';

params.which_frac_ch2_in_ch1 = 'firstmax'; % used since 2012-01-27
% params.which_frac_ch2_in_ch1 = 'mode'; % used before 2012-01-27
% mode, prctile1, prctile5, firstmax
% changed from 'mode' to 'firstmax' on 2012-01-27

% image viewing parameters 
n_channels = 10;
params.viewing_default_min = -1*ones(1,n_channels); % for n_channels channels, i.e. set to minimum intensity
params.viewing_default_max = -0.1*ones(1,n_channels);% for n_channels channels, i.e. saturate 0.1%
params.viewing_default_gamma = 1*ones(1,n_channels);% for n_channels channels
switch lower(record.experiment)
    case '10.24'
        params.viewing_default_min = -1*ones(1,n_channels); % for ten channels, i.e. set to minimum intensity
        params.viewing_default_max = -0.1*ones(1,n_channels);% for ten channels, i.e. saturate 0.1%
        params.viewing_default_max(2) = -1;%
        warning('TPPROCESSPARAMS:SATURATE_CHANNEL2','TPPROCESSPARAMS: default viewing of channel 2 to saturate 1%%.');
        warning('OFF','TPPROCESSPARAMS:SATURATE_CHANNEL2')
    case '11.21'
        params.viewing_default_min = -1*ones(1,n_channels); % for n_channels channels, i.e. set to minimum intensity
        params.viewing_default_max = -0.1*ones(1,n_channels);% for n_channels channels, i.e. saturate 0.1%
    case '11.74' %Mariangela
        params.viewing_default_min = -1*ones(1,n_channels); % for n_channels channels, i.e. set to minimum intensity
        params.viewing_default_max = -0.1*ones(1,n_channels);% for n_channels channels, i.e. saturate 0.1%
        params.viewing_default_max(2) = -1;%
        warning('TPPROCESSPARAMS:SATURATE_CHANNEL2','TPPROCESSPARAMS: default viewing of channel 2 to saturate 1%%.');
        warning('OFF','TPPROCESSPARAMS:SATURATE_CHANNEL2')
    case '10.38'
        params.viewing_default_min = zeros(1,n_channels); % for n_channels channels, i.e. set to minimum intensity
        params.viewing_default_min(2) = -1; % i.e. set to minimum intensity
        params.viewing_default_max = -0.1*ones(1,n_channels);% for n_channels channels, i.e. saturate 0.1%
end


params.tp_monitor_threshold_level = 0.01;


% alignment parameters
switch lower(record.experiment)
    otherwise
        params.align_channel = 2; % for Daan's original stacks
end

% maximum distance for linking ROI to neurite
switch record.experiment
    case '11.21'
        if isempty(findstr(record.stack,'overview'))
            params.max_roi_linking_distance_um = 4;
        else
            params.max_roi_linking_distance_um = 500; 
        end
    case '10.24' 
        params.max_roi_linking_distance_um = 4; 
    otherwise
        params.max_roi_linking_distance_um = 4;
end

params.cell_colors = repmat('kbgrcmy',1,50);


% measures to compute time xz for
params.series_measures = ['present','lost','gained','timepoint',tpstacktypes(record),tpstacklabels(record)];

% new neurite
switch record.experiment
    case '11.12'
        params.newneuritetype = 'axon';
    otherwise
        params.newneuritetype = 'dendrite';
end

% maximum bouton to mitochrondion 
params.max_bouton_mito_distance_um = 2; 

params.bouton_close_minimum_intensity_rel2dendrite = zeros(1,100); %max 100 channels

% get intensities
params.get_intensities = false;
switch record.experiment
    case {'12.81','Examples','14.26'}
        params.get_intensities = true;
    case '13.29' % dani cr
        switch lower(record.setup)
            case 'lif'
                params.get_intensities = true;
        end
end
params.tp_rank_only_present = true;


% loudly complain about absent data
params.tp_mumble_not_present = false;

% stimulus analysis
params.psth_posttime = 3; % for psth viewing only
params.separation_from_prev_stim_off = 1.5; % separation from previous stim offset for analysing baseline, can be negative
params.response_window = [0.5 inf]; % used for measuring response relative to stim onset
params.responsive_alpha = 0.1; % could also be 0.05, used in ttest to determine cell is responsive
switch lower(record.experiment)
    case 'examples'
        params.separation_from_prev_stim_off = 0.5;
        params.response_window = [0.5 inf];
end
params.psth_windowsize = 1; %s, the size of a sliding window for computing average
%  responses and the standard deviation and standard error (in seconds).
params.psth_stepsize = 0.1; %s, the window step size (in seconds).
params.blankstimid = []; % the stimulus number of the blank stimulus, or [] for automatic detection.
params.psth_baselinemethod = 0; % the baseline used to identify F in dF/F.
%  0 means spontaneous interval preceding each stimulus.
%  3 means filter the data and use the blank stimulus (if there is one)
%    for baseline.

params.psth_align_stim_onset = false; % to align df/f at t = 0
params.mti_timeshift = 0.058; % ms for Fluoview scope

switch record.datatype
    case 'tp'
        params.response_channel = 1; % assuming OGB, GCaMP on first channel
    case 'fret'
        params.response_channel = [1 2];
    otherwise
        params.response_channel = 1;
end

params.response_projection_method = 'max';  
%  PROJECTION_METHOD determines how to handle when there is more than one
%       stimulus parameter
%       'none' - do no project
%       'mean' - use response mean over other stimulus parameters
%       'max' - use response maximum over other stimulus parameters
% Should later be handled as for ec data

params.response_baselinemethod = 0; 
% BASELINEMETHOD determines how the baseline is calculated:
%     0  - Use the data collected during the previous ISI
%     1  - Use the closest blank stimulus
%     2  - Use a 20s window of ISI and blank values.
%     3  - Filter data with 240s highpass and use mean




% if datenumber(record.date)<datenumber('2014-07-01') % time when introduced new pixelshift
%     params.pixelshift_pixel = 14;
%     logmsg('Pixelshift specified in pixels. Deprecated since 2014-07-01');
% else
params.pixelshift_um = 5; % overrides pixelshift_pixel
% end

% extra analysis functions
% switch record.experiment
%     case '11.12'
%         params.extra_functions = {'tp_mito_close'};
%     otherwise
%         params.extra_functions = {'tp_get_distance_from_pia'};
% end

params.darklevel_determination = 'none';
switch record.experiment
    case '13.61'
        params.darklevel_determination = '5percentile';
end

% MOVIETYPE is 'plain' or 'twocolor'
params.movietype = 'twocolor'; % or 'plain';
params.movie_sync_factor = 1.02;

% tpquickmap
params.map_method = 'threshold';
params.map_param1 = 0.05; % threshold response level

% blinding
params.blind_fields = {'date','slice','laser','location','comment','mouse','ref_transform'};
params.blind_shuffle = true;
switch lower(record.experiment)
    case '10.24' 
        params.blind_shuffle = false;
    case {'11.12','11.21','12.81'}    
        params.blind_shuffle = false;
    case '14.35' 
        params.blind_shuffle = false;
    case '11.12_rr'
        params.blind_fields = {'date','slice','laser','location','comment','mouse'};
        params.blind_shuffle = true;
end
params.blind_stacks_with_specific_shuffle = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keep at bottom

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    %     changed_process_parameters(params,oldparams);
end



