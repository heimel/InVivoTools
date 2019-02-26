function record = analyse_wctestrecord( record, verbose )
%ANALYSE_WCTESTRECORD analyses webcam testrecord
%
%  RECORD = ANALYSE_WCTESTRECORD( RECORD, VERBOSE=true )
%
% 2015-2019, Alexander Heimel
%

if nargin<2 || isempty(verbose)
    verbose = true;
end

par = wcprocessparams( record );

wcinfo = wc_getmovieinfo( record);
if isempty(wcinfo)
    logmsg(['Could not get movie info for ' recordfilter(record)]);
    return
end

filename = fullfile(wcinfo.path,wcinfo.mp4name);

stimsfile = getstimsfile(record);
if isempty(stimsfile)
    logmsg(['No stimsfile for ' recordfilter(record)]);
    return
end
stims = get(stimsfile.saveScript);

if length(stims)>1
    warning('Only implemented for one stim at the time');
end

stimparams = getparameters(stims{1});
if isfield(stimparams,'start_position')
    startside = stimparams.start_position;
else
    startside = NaN;
end
rec = 1;

stimStart = wcinfo(rec).stimstart * par.wc_timemultiplier;


if par.use_legacy_videoreader
    
    if isempty(record.stimstartframe)
        if isfield(record.measures,'peakPoints')
            peakPoints = record.measures.peakPoints;
        else
            error('Stimulus onset is not determined. use "track" button')
        end
    else
        stimStart = record.stimstartframe / 30;
        peakPoints = [];
    end

    [freezeTimes, nose, arse, stim, mouse_move, move_2der, trajectory_length,...
        averageMovement,minimalMovement,difTreshold,deriv2Tresh, freeze_duration] = ...
        trackmouseblack_pi_legacy(filename,false,stimStart,startside,peakPoints, record);
    
    record.measures.freezetimes = freezeTimes;
    record.measures.nose = nose;
    record.measures.arse = arse;
    record.measures.stim = stim;
    record.measures.mousemove = mouse_move;
    record.measures.move2der = move_2der;
    record.measures.trajectorylength = trajectory_length;
    record.measures.averagemovement = averageMovement;
    record.measures.minimalmovement = minimalMovement;
    record.measures.diftreshold = difTreshold;
    record.measures.deriv2tresh = deriv2Tresh;
    
    record.measures.freeze_duration = freeze_duration;
    record.measures.freezing_computed = ~isempty(freezeTimes);
    
    manualoverride=regexp(record.comment,'freezing=(\s*\d+)','tokens');
    if ~isempty(manualoverride)
        record.measures.freezing = manualoverride{1};
    else
        record.measures.freezing = record.measures.freezing_computed;
    end
    
    if ~isempty(freezeTimes)
        [head_theta, pos_theta] = angle_cal(record);
        if ~isempty(head_theta)
            record.measures.head_theta = head_theta;
            record.measures.pos_theta = pos_theta;
        else
            record.measures.head_theta = {NaN};
            record.measures.pos_theta = {NaN};
        end
    else
        record.measures.head_theta = NaN;
        record.measures.pos_theta = NaN;
    end
    
    %     [freezeTimes, nose, arse, stim, mouse_move, move_2der, trajectory_length,...
    %         averageMovement,minimalMovement,difTreshold,deriv2Tresh, freeze_duration] = ...
    %         trackmouseblack_pi(filename,false,stimStart,startside,peakPoints, record);
end

try
    record = wc_track_mouse(record, [], verbose);
    record = wc_interpret_tracking(record,verbose);
catch me
    errormsg(me.message);
end

