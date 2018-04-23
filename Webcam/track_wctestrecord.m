function record = track_wctestrecord( record, verbose )
%ANALYSE_WCTESTRECORD analyses webcam testrecord
%
%  RECORD = ANALYSE_WCTESTRECORD( RECORD, VERBOSE=true )
%
% 2015-2018, Alexander Heimel
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

record.measures = [];
record.measures.stimstart = stimStart;

[frameRate, arena] = get_arena(filename, stimStart, record);

record.measures.frameRate = frameRate;
record.measures.arena = arena;

if par.use_legacy_videoreader
    [brightness, thresholdsStimOnset, peakPoints] = ...
        search_stim_onset_legacy(filename, stimStart, arena, frameRate);
else
    [brightness, thresholdsStimOnset, peakPoints] = ...
        search_stim_onset(filename, stimStart, arena, frameRate);
end

record.measures.brightness = brightness;
record.measures.thresholdsStimOnset = thresholdsStimOnset;
record.measures.peakPoints = peakPoints;




% % record.measures.freezing_computed = ~isempty(freezeTimes);
% 
% manualoverride=regexp(record.comment,'freezing=(\s*\d+)','tokens');
% if ~isempty(manualoverride)
%     record.measures.freezing = manualoverride{1};
% else
%     record.measures.freezing = record.measures.freezing_computed;
% end
