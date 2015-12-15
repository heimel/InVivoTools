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

 stimStart = round(wcinfo(rec).stimstart * 1.015*100)/100 ;%-1.2; %Factor for fixing delay (1/015) -0.8 correction %1.01445 more precisely %(stimstart*1.01445);

 
[freezeTimes, flightTimes, pos_theta, head_theta, approach] = ...
    trackmouseblack_pi(filename,false,stimStart,startside)

record.measures.freezeTimes = freezeTimes;
record.measures.flightTimes = freezeTimes;