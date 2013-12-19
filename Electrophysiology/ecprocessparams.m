function params = ecprocessparams( record )
%ECPROCESSPARAMS parameters for ec and lfp analysis
%
% 2012-2013, Alexander Heimel
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
params.pre_window = [-Inf 0];
params.post_window = [0 Inf];
params.separation_from_prev_stim_off = 0.5;  % time (s) to stay clear of prev_stim_off
%params.early_response_window = [0.05 0.2];  % not implemented yet
%params.late_response_window = [0.5 inf]; % not implemented yet


switch protocol
    case '11.35'
        params.pre_window = [-inf 0];
        params.post_window = [0 inf];
        disp(['ECPROCESSPARAMS: Setting pre_window to ' mat2str(params.pre_window)]);
            case '13.20'
%         params.pre_window = [-0.5 0];
%         params.post_window = [0 0.5];
        disp(['ECPROCESSPARAMS: Setting pre_window to ' mat2str(params.pre_window)]);
        disp(['ECPROCESSPARAMS: Setting post_window to ' mat2str(params.post_window)]);
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

% params.pre_window = [-inf 0];
%
% params.post_window = [0 inf];

params.vep_log10_freqs = true;

params.take_bgpretime_from_offset = 0.5; % discard first X seconds of BGpretime

params.cell_colors = repmat('kbgrcmy',1,50);


% spike isolation
params.cluster_overlap_threshold = 0.5;

% entropy analysis
switch record.mouse(1:min(end,5))
    case '12.28'
        params.entropy_analysis = false;
    otherwise
        params.entropy_analysis = false;
end


switch lower(record.setup)
    case {'antigua','daneel'}
        params.sort_with_klustakwik = false;
        params.compare_with_klustakwik = false;
    otherwise
        switch record.mouse(1:min(end,5))
            case {'05.01','07.30'}
                params.sort_with_klustakwik = false;
                params.compare_with_klustakwik = false;
            case {'13.20'}
                params.sort_with_klustakwik = true;
                params.compare_with_klustakwik = true;
            otherwise
                params.sort_with_klustakwik = false;
                params.compare_with_klustakwik = true;
        end
end

% time calibration
switch lower(record.setup)
    case 'antigua' 
        params.trial_ttl_delay=0.00; % s delay of visual stimulus after trial start TTL
        params.secondsmultiplier=1.000017000; % multiplification factor of electrophysical signal time
    otherwise
        warning('ECPROCESSPARAMS:TIMING','ECPROCESSPARAMS: Setup not time calibrated yet');
        warning('off', 'ECPROCESSPARAMS:TIMING');

end
