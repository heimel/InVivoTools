function par = wcprocessparams( record )
%WCPROCESSPARAMS sets parameters for webcam recording
%
% 2015-2018, Alexander Heimel

% set player
if isunix && ~ismac
    par.wc_player = 'vlc' ;
    [status,out] = system(['which ' par.wc_player]);
    if status==0
        par.wc_playercommand = strtrim(out) ;
    else
        par.wc_player = 'totem';
        [status,out] = system(['which ' par.wc_player]);
        if status==0
            par.wc_playercommand = strtrim(out);
        else
            par.wc_playercommand = '';
        end
    end
elseif ismac
    par.wc_player = 'VLC'; 
    par.wc_playercommand = 'open -a VLC' ;
else
    par.wc_player = 'vlc'; 
    par.wc_playercommand = 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe' ;
    if ~exist(par.wc_playercommand,'file')
        par.wc_playercommand = 'C:\Program Files\VideoLAN\VLC\vlc.exe' ;
    end
    if ~exist(par.wc_playercommand,'file')
        par.wc_playercommand = '';
    end
    if exist(par.wc_playercommand,'file')
        par.wc_playercommand=['"' par.wc_playercommand '"'];
    end
end

% set mp4 wrapper
par.wc_mp4wrappercommand = '';
if isunix 
    par.wc_mp4wrappercommand = 'MP4Box -fps 30 -add ' ;
else
    if exist('C:\Program Files\GPAC\mp4box.exe','file')
        par.wc_mp4wrappercommand =  '"C:\Program Files\GPAC\mp4box.exe" -fps 30 -add ';
    elseif exist('C:\Toolbox\ffmpeg\bin\ffmpeg.exe','file')
        par.wc_mp4wrappercommand = 'C:\Toolbox\ffmpeg\bin\ffmpeg.exe  -c:v copy -f mp4 -i ';
    else
        warning('WCPROCESSPARAMS:INSTALL_FFMPEG','Install ffmpeg (https://ffmpeg.org) in C:\\Toolbox\\ffmpeg or install mp4box');
        warning('off','WCPROCESSPARAMS:INSTALL_FFMPEG');
    end
end

par.wc_playbackpretime = 0; % s to show before stim onset
% par.wc_timemultiplier = 1.01445;
par.wc_timemultiplier = 1.015355;
par.wc_timeshift = -0.5;

if ismac
    par.use_legacy_play_wctestrecord = false;
else
    par.use_legacy_play_wctestrecord = true;
end

if exist('processparams_local.m','file')
    par = processparams_local( par );
end

