function [newtimes,frame2dirnum] = tpcorrecttptimes( records )
% TPCORRECTTPTIMES - Corrects time for prairieview twophoton files
%
%   [FRAMETIMES,FRAME2DIRNUM] = ...
%     TPCORRECTTPTIMES({PARAMSTRUCT}, TIMEFILENAME)
%
%  Corrects the self-reported frame triggers of the acquired
%  two-photon data to be consistent with the clock on the stimulus
%  presentation machine.
%
%  FRAMETIMES are the beginning times for each two-photon
%  frame, relative to the stimulus machine clock, measured in
%  seconds.
%
%  FRAME2DIRNUM is an array of numbers that indicate
%  which data directory corresponds to each recorded
%  frame.  For example, FRAME2DIRNAME(1) is the
%  data directory number that contains the data
%  for recorded two-photon frame 1.

disp('tpcorrecttptimes: for lohmann no frametime correction')
disp('tpcorrecttptimes: artificial start times: epoch * 1000 s (= 16 min)')
disp('tpcorrecttptimes: time is relative to time 0 for first record')

if length(records)==1
    params = tpreadconfig(records);
    newtimes = params.frame_timestamp;
    frame2dirnum = ones(size(newtimes));
else
 %   starttime = 0;
    for i=1:length(records)
        starttime = str2double(records(i).epoch(records(i).epoch(:)>='0'&records(i).epoch(:)<='9'  ))*1000; 
        params = tpreadconfig(records(i));
        newtimes{i} = starttime + params.frame_timestamp ;
        frame2dirnum{i} = ones(size(newtimes{i}));
%        starttime = newtimes{i}(end) + 60; % i.e. assume an arbitrary minute between subsequent epochs
    end
end
