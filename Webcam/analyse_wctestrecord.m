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
logmsg(['Found ' num2str(length(d)) ' webcam records in ' experimentpath(record)]);
for i = 1:length(d)
    wcinfo(i) = load(fullfile(experimentpath(record),d(i).name));
    
    [pth,wcinfo(i).filename] = fileparts(wcinfo(i).filename);
    wcinfo(i).filename = [wcinfo(i).filename '.h264'];
end

% create mp4 wrappers
parpath = fullfile(experimentpath(record),'..');
for i=1:length(d)
    wcinfo(i).mp4name = [ wcinfo(i).filename '.mp4'];
    if  ~exist(wcinfo(i).mp4name,'file')
        if isunix
            cmd = ['MP4Box -fps 30 -add "' fullfile(parpath,wcinfo(i).filename) '" "' fullfile(parpath,wcinfo(i).mp4name) '"']
            [stat,output ] = system(cmd)
        else
            logmsg(['Cannot create mp4 wrapper for ' fullfile(parpath,wcinfo(i).filename) '. Try on linux computer, or run sudo apt-get -y install gpac']);
        end
    end
end

for i=1:length(wcinfo)
    logmsg(['Recorded in ' fullfile(parpath,wcinfo(i).filename)]);
    logmsg(['Stimulus started: ' num2str(wcinfo(i).stimstart)]);
end


% 
% player = 'totem';
% [status,out] = system([ player ' ' wcinfo(1).mp4name ]);