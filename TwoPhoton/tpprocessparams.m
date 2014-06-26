function params = tpprocessparams( method, record )
%TPPROCESSPARAMS returns default two-photon calcium data processing parameters
%
% PARAMS = TPPROCESSPARAMS( METHOD )
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2009-2013, Alexander Heimel
%

if nargin<1
    method = [];
end
if isempty(method)
    method = 'none';
end
if nargin<2
    record.setup = 'olympus-0603301';
    record.experiment = '10.38'; % fairly arbitrary calcium imaging protocol
end

params.method = method;      

switch method
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


switch host
    case 'nin158' % friederike
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
params.detect_events_threshold = 2;%1 %;2.5; % (std)
params.detect_events_minpeakdistance = 2;%0.5; % (seconds) minimum distance between two peaks
params.detect_events_max_time_before_peak = 4;%2; % seconds to include in event before peak
params.detect_events_max_time_after_peak = 4;%2; % seconds to include in event after peak
params.detect_events_margin = 0;% 0.2; % (seconds) margin to find minimum and half maximum for peak interval
params.detect_events_fit_slope = true; % use the derivative of the signal to fit onset time
params.detect_events_group = true;
params.detect_events_group_width = 0.4;%0.7;%0.5; %0.4; %2;%4-8-2010: 4;% 1;% (seconds) minimum interval between two global events
params.detect_events_group_minimum_cell_number = 0.1; % if smaller than 1, then it is interpreted as fraction
params.detect_events_time = 'peak';
params.detect_events_fit_slope = false;
params.findpeaks_fast = false; % use findpeaks fast

switch record.experiment
    case '12.98' % Rogier
       params.detect_events_threshold = 2.5;%1 %;2.5; % (std) 
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


% alignment parameters
switch lower(record.experiment)
    otherwise
        params.align_channel = 2; % for Daan's original stacks
end


% change user specific options
switch host
    case 'nin326' % juliette
        params.detect_events_threshold = 3;%1 %;2.5; % (std)
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

% stimulus analysis
switch lower(record.experiment)
    case 'examples'
        params.separation_from_prev_stim_off = 0.5;
        params.response_window = [0.5 inf];
    otherwise
        params.separation_from_prev_stim_off = 1.5; % high for GCaMPs
        params.response_window = [0.5 inf];
end
params.responsive_alpha = 0.1; % could also be 0.05


% extra analysis functions
% switch record.experiment
%     case '11.12'
%         params.extra_functions = {'tp_mito_close'};
%     otherwise
%         params.extra_functions = {'tp_get_distance_from_pia'};
% end

if exist('processparams_local.m','file')
    logmsg('Overriding tpprocessparams with possible local settings');
    params = processparams_local( params );
end
