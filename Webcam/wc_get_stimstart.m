function stimstart = wc_get_stimstart(record)
%WC_GET_STIMSTART gets best estimate of stimstart from record
%
% 2020, Alexander Heimel

if ~isempty(record.stimstartframe)
    stimstart = record.stimstartframe/30;
    
    %     vid = VideoReader(filename);
    %     stimStart = record.stimstartframe / vid.frameRate;
elseif isfield(record.measures,'stimstart')
    logmsg(['No stimstartframe in ' recordfilter(record)]);
    stimstart = record.measures.stimstart;
else
    wcinfo = wc_getmovieinfo(record);
    if isempty(wcinfo)
        logmsg(['Could not get movie info for ' recordfilter(record)]);
        stimstart = [];
    elseif ~isempty(wcinfo.stimstart)
        logmsg(['Calculating stimstartframe for ' recordfilter(record)]);
        params = wcprocessparams(record);
        stimstart = (wcinfo(1).stimstart-params.wc_playbackpretime) * params.wc_timemultiplier + params.wc_timeshift;
    else
        logmsg(['No stimstartframe and no stimstart field in ' recordfilter(record)]);
        stimstart = [];
    end
end

