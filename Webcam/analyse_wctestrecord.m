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

params = wcprocessparams( record );

record = wc_postanalysis( record,verbose ); % also run at the end. run here if the data cannot be found

[wcinfo,filename] = wc_getmovieinfo( record);
if isempty(wcinfo)
    logmsg(['Could not get movie info for ' recordfilter(record)]);
    return
end

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

stimStart = wcinfo(rec).stimstart * params.wc_timemultiplier;

if params.use_legacy_videoreader
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
end

if params.wc_redraw_arena || ~isfield(record.measures,'arena') || isempty(record.measures.arena)
    record = wc_get_arena(record);
end
if ~isfield(record.measures,'frametimes') || params.wc_retrack
    record = wc_track_mouse(record, [], verbose);
end
if ~strcmp(record.stim_type,'gray_screen') && ~isempty(record.stim_type)
    record = wc_cleanup_stimulus_trajectory(record,verbose);
end
record = wc_interpret_tracking(record,verbose);
record = wc_postanalysis( record,verbose); 

