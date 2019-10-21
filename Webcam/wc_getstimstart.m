function stimstart = wc_getstimstart( record, framerate )
%WC_GETSTIMSTART returns the most accurate stimstart available
%
%  STIMSTART = WC_GETSTIMSTART( RECORD )
%
% 2019, Alexander Heimel

if nargin<2
    framerate = [];
end

if isfield(record,'stimstartframe') && ~isempty(record.stimstartframe)
    if isempty(framerate)
        [~,filename] = wc_getmovieinfo(record);
        vid = VideoReader(filename);
        framerate = vid.FrameRate;
    end
    stimstart = record.stimstartframe / framerate;
    return
end

wcinfo = wc_getmovieinfo(record);
if isfield(wcinfo,'real_stimstart') && ~isempty(wcinfo(1).real_stimstart)
    stimstart = wcinfo(1).real_stimstart;
    return
end

if isfield(wcinfo,'stimstart') && ~isempty(wcinfo.stimstart)
    params = wcprocessparams( record );
    stimstart = (wcinfo(1).stimstart-params.wc_playbackpretime) * params.wc_timemultiplier + params.wc_timeshift;
    return
end

logmsg(['No stimstartframe or stimstart available for ' recordfilter(record)]);
stimstart = 0;
