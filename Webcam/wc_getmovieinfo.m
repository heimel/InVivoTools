function [wcinfo,filename] = wc_getmovieinfo( record)
%WC_GETMOVIEINFO gets info about recorded webcam movies
%
% [WCINFO,FILENAME] = WC_GETMOVIEINFO( RECORD )
%    FILENAME is full mp4 filename including path and extension
%
% 2015-2020, Alexander Heimel

par = wcprocessparams(record);

filename = [];
d = dir(fullfile(experimentpath(record),'webcam*info.mat'));
%logmsg(['Found ' num2str(length(d)) ' webcam records in ' experimentpath(record)]);
if isempty(d)
    wcinfo = [];
    return
end

for i = 1:length(d)
    wcinfo(i) = load(fullfile(experimentpath(record),d(i).name));
    [pth,wcinfo(i).filename] = fileparts(wcinfo(i).filename);
    wcinfo(i).filename = [wcinfo(i).filename '.h264'];
end

for i=1:length(d)
    if isempty(wcinfo(i).stimstart)
        logmsg(['Empty stimstart in ' recordfilter(record)]);
        comment = record.comment;
        comment(comment==' ')=[];
        
        ind = strfind(comment,'start=');
        if isempty(ind)
            errormsg('No stimstart in wcinfo. Add starttime to comment field, as ''start=XX:XX;''. note semicolon at end');
            return
        end
        ind2 = find(comment(ind:end)==':');
        if isempty(ind2)
            errormsg('Missing colon in start=XX:XX;');
            return
        end
        ind3 = find(comment(ind:end)==';');
        if isempty(ind3)
            errormsg('Missing semicolon in start=XX:XX;');
            return
        end
        minutes = str2double(comment(ind+6:ind+ind2-2));
        seconds = str2double(comment(ind+ind2:ind+ind3-2));
        wcinfo(i).real_stimstart = minutes*60+seconds;
        wcinfo(i).stimstart = (wcinfo(i).real_stimstart-par.wc_timeshift)/par.wc_timemultiplier ;
        
    end
end

% create mp4 wrappers
parpath = fullfile(experimentpath(record),'..');

if ~isempty(par.wc_mp4wrappercommand)
    for i=1:length(d)
        wcinfo(i).path = parpath;
        wcinfo(i).mp4name = [ wcinfo(i).filename '.mp4'];
        if  ~exist(fullfile(parpath,wcinfo(i).mp4name),'file') || ...
                getfield(dir(fullfile(parpath,wcinfo(i).mp4name)),'datenum')<getfield(dir(fullfile(parpath,wcinfo(i).filename)),'datenum')
            if exist(fullfile(parpath,wcinfo(i).mp4name),'file')
                logmsg(['Backing up ' fullfile(wcinfo(i).path,wcinfo(i).mp4name)]);
                movefile(fullfile(wcinfo(i).path,wcinfo(i).mp4name),fullfile(wcinfo(i).path ,[wcinfo(i).mp4name '.bak']));
            end
            logmsg(['Creating mp4 wrapper ' fullfile(parpath,wcinfo(i).filename)]);
            cmd = [par.wc_mp4wrappercommand ' "' fullfile(parpath,wcinfo(i).filename) '" "' fullfile(parpath,wcinfo(i).mp4name) '"'];
            [stat,output ] = system(cmd);
            if stat==0
                logmsg(['Created mp4 wrapper ' fullfile(parpath,wcinfo(i).filename)]);
            elseif stat==127
                logmsg(['Cannot create mp4 wrapper for ' fullfile(parpath,wcinfo(i).filename) '. Run sudo apt-get -y install gpac']);
            else
                logmsg(['Cannot create mp4 wrapper for ' fullfile(parpath,wcinfo(i).filename) '. ' output]);
            end
        end
    end
else
    for i=1:length(d)
        wcinfo(i).path = parpath;
        wcinfo(i).mp4name = [ wcinfo(i).filename '.mp4'];
    end
    if ~exist(fullfile(parpath,wcinfo(i).mp4name),'file')
        logmsg(['Cannot create mp4 wrapper for ' fullfile(parpath,wcinfo(i).filename) '. Try on linux computer, or run sudo apt-get -y install gpac']);
    end
end

for i=1:length(wcinfo)
    wcinfo(i).real_stimstart = (wcinfo(i).stimstart)*par.wc_timemultiplier  + par.wc_timeshift ;
%    logmsg(['Recorded in ' fullfile(parpath,wcinfo(i).filename)]);
%    logmsg(['Stimulus started original: ' num2str(wcinfo(i).stimstart) ' s, ' ...
%        'corrected: ' num2str(wcinfo(i).real_stimstart) ' s' ]);
end

filename = fullfile(wcinfo.path,wcinfo.mp4name);
