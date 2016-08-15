function play_wctestrecord(record)
%PLAY_WCTESTRECORD plays webcam movie
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
try
    logmsg('Running video in matlab');
    vid=VideoReader(filename);
    
    
    %Get paramters of video
    numFrames = get(vid, 'NumberOfFrames');
    frameRate = get(vid, 'FrameRate'); %30 frames/sec
    frame = round(starttime*frameRate);
    
    figure
    changed = true;
    prevnokey = true;
    while   1
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
    %snapframe = read(vid, i);%+vidlag
catch me
    logmsg(['Some problem: ' me.message]);
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