function play_wctestrecord_legacy(record)
%PLAY_WCTESTRECORD plays webcam movie
%Press down arrow key for normal play, up arrow to halt, right and left arrow keys to go
%forward and back a frame respectively, and q to quit play
%
% Using frame as dominant, rather than time (as in pre matlab 2016)
%
% 2015, Alexander Heimel

par = wcprocessparams( record );

if isempty(par.wc_playercommand)
    errormsg('No videoplayer found. Add line to processparms_local.m with par.wc_playercommand to set player.');
    return
end

wcinfo = wc_getmovieinfo( record);

if isempty(wcinfo)
    errormsg(['No movie found for ' recordfilter(record)]);
    return
end

starttime = (wcinfo(1).stimstart-par.wc_playbackpretime) * par.wc_timemultiplier + par.wc_timeshift;

filename = fullfile(wcinfo.path,wcinfo.mp4name);
vid_name = [sprintf('%s', record.mouse,'-', record.date,'-', record.epoch) '.avi'];

logmsg('Running video in matlab');
vid=VideoReader(filename);

%Get paramters of video
numFrames = get(vid, 'NumberOfFrames');
frameRate = get(vid, 'FrameRate'); %30 frames/sec

if ~isempty(record.stimstartframe)
    frame = record.stimstartframe;
else
    frame = round(starttime*frameRate);
end

figure;
changed = true;
prevnokey = true;
makeVideo = 1;
work_path = cd; 
vid_sav_path = fullfile(wcinfo.path, record.epoch);

while 1
    if changed
        imframe = read(vid, frame);
        image(imframe);
        changed = false;
        logmsg(['Frame = ' num2str(frame) ', Time = ' num2str(frame/frameRate)]);
        drawnow
        WaitSecs(1/frameRate);
    else
        WaitSecs(0.01);
    end
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if ~keyIsDown && ~prevnokey
        prevnokey = true;
    end
    if keyIsDown && prevnokey
        switch find(keyCode,1)
            case 40 %arrow down 
                
                if makeVideo
                    cd(vid_sav_path)
                    writerObj = VideoWriter(vid_name); %#ok<UNRCH>
                    writerObj.FrameRate = frameRate;
                    open(writerObj);
                    cd(work_path);
                end
                
                while 1
                    vidFrame = read(vid, frame);
                    image(vidFrame);
                    drawnow
                    pause(1/frameRate);
                    frame = frame+1;
                    if makeVideo
                        frames = getframe; %#ok<UNRCH>
                        cd(vid_sav_path)
                        writeVideo(writerObj,frames);
                        cd(work_path);
                        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
                        if keyIsDown && find(keyCode,1)==38 % arrow up
                            if makeVideo
                                cd(vid_sav_path)
                                close(writerObj); %#ok<UNRCH>
                                cd(work_path);
                            end
                        
                        break
                        
                        end
                    end 
                end
                changed = false;
                prevnokey = false;
                
            case 37 % arrow left
                if frame>1
                    frame = frame - 1;
                    changed = true;
                    prevnokey = false;
                else
                    logmsg('Reached start of movie');
                end
                
            case 39 % arrow right
                if frame<numFrames
                    frame = frame +1;
                    changed = true;
                    prevnokey = false;
                else
                    logmsg('Reached end of movie');
                end
                
            case 81 % q
                break
        end
    end
end

return


cmd = par.wc_playercommand;
switch par.wc_player
    case 'vlc'
        cmd = [ cmd ' --start-time=' num2str(starttime)];
end

cmd = [ cmd ' "' fullfile(    wcinfo(rec).path,wcinfo(rec).mp4name) '"'];

switch par.wc_player
    case 'vlc'
        logmsg('Press ''p'' to replay.');
end

logmsg(cmd);
[status,out] = system(cmd);

out