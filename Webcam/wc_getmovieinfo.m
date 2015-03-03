function wcinfo = wc_getmovieinfo( record)
%WC_GETMOVIEINFO gets info about recorded webcam movies
%
% WCINFO = WC_GETMOVIEINFO( RECORD )
%
% 2015, Alexander Heimel

d = dir(fullfile(experimentpath(record),'webcam*info.mat'));
logmsg(['Found ' num2str(length(d)) ' webcam records in ' experimentpath(record)]);
if isempty(d)
    return
end

for i = 1:length(d)
    wcinfo(i) = load(fullfile(experimentpath(record),d(i).name));
    
    [pth,wcinfo(i).filename] = fileparts(wcinfo(i).filename);
    wcinfo(i).filename = [wcinfo(i).filename '.h264'];
end

% create mp4 wrappers
parpath = fullfile(experimentpath(record),'..');
for i=1:length(d)
    wcinfo(i).path = parpath;
    wcinfo(i).mp4name = [ wcinfo(i).filename '.mp4'];
    if  ~exist(fullfile(parpath,wcinfo(i).mp4name),'file')
        if isunix
            cmd = ['MP4Box -fps 30 -add "' fullfile(parpath,wcinfo(i).filename) '" "' fullfile(parpath,wcinfo(i).mp4name) '"'];
            [stat,output ] = system(cmd);
            if stat==0
                logmsg(['Created mp4 wrapper ' fullfile(parpath,wcinfo(i).filename)]);
            elseif stat==127
                logmsg(['Cannot create mp4 wrapper for ' fullfile(parpath,wcinfo(i).filename) '. Run sudo apt-get -y install gpac']);
            end
        else
            logmsg(['Cannot create mp4 wrapper for ' fullfile(parpath,wcinfo(i).filename) '. Try on linux computer, or run sudo apt-get -y install gpac']);
        end
    end
end

for i=1:length(wcinfo)
    logmsg(['Recorded in ' fullfile(parpath,wcinfo(i).filename)]);
    logmsg(['Stimulus started: ' num2str(wcinfo(i).stimstart) ' s = '...
        num2str(floor(wcinfo(i).stimstart/60)) ':' num2str(wcinfo(i).stimstart-60*floor(wcinfo(i).stimstart/60),'%02.2f')   ]);
end
