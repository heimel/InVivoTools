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

d = dir(fullfile(experimentpath(record),'webcam*info.mat'));
for i = 1:length(d)
    wcinfo(i) = load(fullfile(experimentpath(record),d(i).name));
end

% create mp4 wrappers
for i=1:length(d)
    wcinfo(i).mp4name = [ wcinfo(i).filename '.mp4'];
    if  ~exist(wcinfo(i).mp4name,'file')
        if isunix
            [stat,output ] = system(['MP4Box -fps 30 -add ' wcinfo(i).filename ' ' wcinfo(i).mp4name])
        else
            logmsg(['Cannot create mp4 wrapper for ' wcinfo(i).filename '. Try on linux computer.']);
        end
    end
end

for i=1:length(wcinfo)
    logmsg(['Recorded in ' wcinfo(i).filename]);
    logmsg(['Stimulus started: ' num2str(wcinfo(i).stimstart)]);
end



player = 'totem';
[status,out] = system([ player ' ' wcinfo(1).mp4name ]);