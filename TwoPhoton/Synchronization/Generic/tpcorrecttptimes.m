function [newtimes,frame2dirnum] = tpcorrecttptimes(params, dirname)
% TPCORRECTTPTIMES - Corrects time for twophoton files
%   (This is the Generic version, so it just returns the 2P parameter times)
%  
%   [FRAMETIMES,FRAME2DIRNUM] = ...
%     TPCORRECTTPTIMES({PARAMSTRUCT}, DIRNAME)
%
%  PARAMSTRUCT should be a cell list of parameter structures
%  associated with the two-photon data folder as returned by 
%  'readtpconfig' function.  Each two-photon data
%  directory (i.e., TPDATA-001, TPDATA-002, etc) will
%  have its own PARAMSTRUCT, and these should passed in
%  a cell list (i.e., {PARAMSTRUCT001,PARAMSTRUCT002}).
%
%  FRAMETIMES are the beginning times for each two-photon
%  frame measured in seconds.
%
%  FRAME2DIRNUM is an array of numbers that indicate
%  which data directory corresponds to each recorded
%  frame.  For example, FRAME2DIRNAME(1) is the
%  data directory number that contains the data
%  for recorded two-photon frame 1.

frame2dirnum = [];
tpparam_times = [];

for i=1:length(params),
	frame2dirnum = [frame2dirnum repmat(1,1,length(params{i}.Image_TimeStamp__us_))];
	tpparam_times = [ tpparam_times params{i}.Image_TimeStamp__us_*1e-6 ];
end;

newtimes = tpparam_times;

