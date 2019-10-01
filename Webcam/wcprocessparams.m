function params = wcprocessparams( record )
%WCPROCESSPARAMS sets parameters for webcam recording
%
% 2015-2019, Alexander Heimel

if nargin<1
    record = [];
end

% set player
if isunix && ~ismac
    params.wc_player = 'vlc' ;
    [status,out] = system(['which ' params.wc_player]);
    if status==0
        params.wc_playercommand = strtrim(out) ;
    else
        params.wc_player = 'totem';
        [status,out] = system(['which ' params.wc_player]);
        if status==0
            params.wc_playercommand = strtrim(out);
        else
            params.wc_playercommand = '';
        end
    end
elseif ismac
    params.wc_player = 'VLC'; 
    params.wc_playercommand = 'open -a VLC' ;
else
    params.wc_player = 'vlc'; 
    params.wc_playercommand = 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe' ;
    if ~exist(params.wc_playercommand,'file')
        params.wc_playercommand = 'C:\Program Files\VideoLAN\VLC\vlc.exe' ;
    end
    if ~exist(params.wc_playercommand,'file')
        params.wc_playercommand = '';
    end
    if exist(params.wc_playercommand,'file')
        params.wc_playercommand=['"' params.wc_playercommand '"'];
    end
end

% set mp4 wrapper
params.wc_mp4wrappercommand = '';
if isunix 
    params.wc_mp4wrappercommand = 'MP4Box -fps 30 -add ' ;
else
    if exist('C:\Program Files\GPAC\mp4box.exe','file')
        params.wc_mp4wrappercommand =  '"C:\Program Files\GPAC\mp4box.exe" -fps 30 -add ';
    elseif exist('C:\Toolbox\ffmpeg\bin\ffmpeg.exe','file')
        params.wc_mp4wrappercommand = 'C:\Toolbox\ffmpeg\bin\ffmpeg.exe  -c:v copy -f mp4 -i ';
    else
        warning('WCPROCESSPARAMS:INSTALL_FFMPEG','Install ffmpeg (https://ffmpeg.org) in C:\\Toolbox\\ffmpeg or install mp4box');
        warning('off','WCPROCESSPARAMS:INSTALL_FFMPEG');
    end
end

params.wc_playbackpretime = 0; % s to show before stim onset


% params.wc_timemultiplier = 1.01445;

if isfield(record,'date') && datenum(record.date)<=datenum('2018-04-28')
    params.wc_timemultiplier = 1.015355;
    params.wc_timeshift = -0.5;
else % something was changed in the timing of the movies between 2018-04-28 and 2018-04-30
    params.wc_timemultiplier = 1.00058;
    params.wc_timeshift = -0.5;
end


if ismac
    params.use_legacy_videoreader = false;
else
    params.use_legacy_videoreader = true;
end


params.wc_freezeduration_threshold = 0.5; %s minimum duration to call lack of movement a freeze
params.wc_freeze_smoother = [5,5]; % Number of frames that freeze analysis is averaging over before and after current frame
params.wc_analyse_time_before_onset = 2; % s, time to analyse before stimulus starts
params.wc_analyse_time_after_offset = 2; % s, time to analyse after stimulus ends

params.wc_play_gamma = 1; % default gamma to use for showing mouse movies

% freezing detection parameters
params.wc_difScope = 50; % The range around mouse that is included in pixelchange analysis 
params.wc_difThreshold = 0.3; % threshold + minimum movement for difference between frames
% to be considered as no difference, fraction of average movement 
params.wc_deriv2thres = 0.08; % Threshold for 2nd derivative of vidDif for detecting freezing



if exist('processparams_local.m','file')
    params = processparams_local( params );
end

