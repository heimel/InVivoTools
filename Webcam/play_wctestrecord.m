function play_wctestrecord(record)
%PLAY_WCTESTRECORD plays webcam movie
%Press down arrow key for normal play, up arrow to halt, right and left arrow keys to go
%forward and back a frame respectively, and q to quit play
%
% Updated implementation to use readFrame instead of read
% and switch to time dominated from frame dominated
%
% 2015-2018, Alexander Heimel

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

logmsg('Running video in matlab');
if ~exist(filename,'file')
    errormsg([filename ' does not exist. Perhaps need to configure mp4-wrapper?']);
    return
end

vid = VideoReader(filename);

%Get paramters of video
frameRate = get(vid, 'FrameRate'); %30 frames/sec

if ~isempty(record.stimstartframe)
    vid.CurrentTime = record.stimstartframe / frameRate;
else
    vid.CurrentTime = starttime;
end

disp('Keys: left = previous frame, right = next frame, down = play until up, q = quit, + = increase gamma, - = decrease gamma');

fig = figure('Name',['Play ' recordfilter(record)],'NumberTitle','off','MenuBar','none');
changed = true;

gamma = 1;

play = false;

while 1
    if ~hasFrame(vid)
        logmsg('No more frames available');
    elseif changed || play
        imframe = readFrame(vid);
        gimframe = uint8(double(imframe).^gamma / (255^gamma) * 255);
        draw_frame(gimframe,gamma,vid,record)
        changed = false;
    end
    pause(1/frameRate);
    if ~isvalid(fig)
        break;
    end
    figure(fig);
        
    keyCode = double(get(fig,'CurrentCharacter'));
    set(fig,'CurrentCharacter',' ');
    if isempty(keyCode)
        continue
    end
    
    switch keyCode
        case '-'
            gamma = gamma + 0.1;
            draw_frame(imframe,gamma,vid,record);
        case '+'
            if gamma>0.1
                gamma = gamma - 0.1;
            end
            draw_frame(imframe,gamma,vid,record);
        case 31 %arrow down
            play  = true;
        case 30 % arrow down
            play = false;
        case 28 % arrow left
            if vid.CurrentTime >= 2/frameRate
                vid.CurrentTime = vid.CurrentTime - 2/frameRate;
                changed = true;
            else
                logmsg('Reached start of movie');
            end
        case 29 % arrow right
            changed = true;
        case 'q'
            break
    end
end
delete(fig);


function draw_frame(imframe,gamma,vid,record)
gimframe = uint8(double(imframe).^gamma / (255^gamma) * 255);
image(gimframe);
axis image
title([num2str(vid.CurrentTime,'%.2f') ' s - Frame ' num2str(vid.CurrentTime*vid.FrameRate) ]);

if ~isempty(record.measures) && isfield(record.measures,'trajectory') && ~isempty(record.measures.trajectory)
    ind = find(record.measures.trajectory(:,1)>=vid.CurrentTime,1);
    hold on
    plot(record.measures.trajectory(ind,2),record.measures.trajectory(ind,3),'xr');
    hold off
end

draw_screen_outline(record)
drawnow


function draw_screen_outline(record)
% plot screen sides
if ~isempty(record.measures) && isfield(record.measures,'arena') && length(record.measures.arena)==4
    hold on
    a = record.measures.arena;
    line([a(1) a(1)],[a(2) a(2)+a(4)],'color',[1 1 0]);
    line([a(1) a(1)+a(3)],[a(2)+a(4) a(2)+a(4)],'color',[1 1 0]);
    line([a(1)+a(3) a(1)+a(3)],[a(2)+a(4) a(2)],'color',[1 1 0]);
    line([a(1)+a(3) a(1)],[a(2) a(2)],'color',[1 1 0]);
    hold off
end

