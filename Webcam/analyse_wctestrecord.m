function record = analyse_wctestrecord( record, verbose )
%ANALYSE_WCTESTRECORD analyses webcam testrecord
%
%  RECORD = ANALYSE_WCTESTRECORD( RECORD, VERBOSE=true )
%
% 2015, Alexander Heimel
%

if nargin<2
    verbose = [];
end
if isempty(verbose)
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
startside = stimparams.start_position;
rec = 1;
% stimStart = (wcinfo(rec).stimstart-par.wc_playbackpretime) * 1.015

stimStart = round(wcinfo(rec).stimstart * 1.015);%*100)/100 ;%-1.2;
%Factor for fixing delay (1/015) -0.8 correction %1.01445 more precisely %(stimstart*1.01445);


[freezeTimes, nose, arse, stim, mouse_move, mouse_2der] = ...
    trackmouseblack_pi(filename,false,stimStart,startside);

record.measures.freezeTimes = freezeTimes;
% record.measures.flightTimes = flightTimes;
record.measures.nose = nose;
record.measures.arse = arse;
record.measures.stim = stim;

if isempty(freezeTimes) == 0
    [head_theta, pos_theta] = angle_cal(record);
    
    record.measures.head_theta = head_theta;
    record.measures.pos_theta = pos_theta;
else
    record.measures.head_theta = [];
    record.measures.pos_theta = [];
end
