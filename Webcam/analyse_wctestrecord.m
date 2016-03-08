function record = analyse_wctestrecord( record, verbose )
%ANALYSE_WCTESTRECORD analyses webcam testrecord
%
%  RECORD = ANALYSE_WCTESTRECORD( RECORD, VERBOSE=true )
%
% 2015-2016, Alexander Heimel
%

if nargin<2 || isempty(verbose)
    verbose = true;
end

par = wcprocessparams( record );

wcinfo = wc_getmovieinfo( record);
filename = fullfile(wcinfo.path,wcinfo.mp4name);

stimsfile = getstimsfile(record);
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

[pk_frRall, pk_frLall] = search_stim_onset(filename, stimStart);

record.measures.ActStimFrameR = pk_frRall;
record.measures.ActStimFrameL = pk_frLall;

[freezeTimes, nose, arse, stim, mouse_move, move_2der, trajectory_length,...
    averageMovement,minimalMovement,difTreshold,deriv2Tresh,fig_n, freeze_duration] = ...
    trackmouseblack_pi(filename,false,stimStart,startside);

record.measures = [];

record.measures.stimstart = stimStart;
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
record.measures.fign = fig_n;
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
    
    record.measures.head_theta = head_theta;
    record.measures.pos_theta = pos_theta;
else
    record.measures.head_theta = [];
    record.measures.pos_theta = [];
end
