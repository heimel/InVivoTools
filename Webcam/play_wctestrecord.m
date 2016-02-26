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


filename = fullfile(wcinfo.path,wcinfo.mp4name);
try 
    vid=VideoReader(filename);
catch me
    logmsg(['Some problem: ' me.message]);
end

% %Get paramters of video
% numFrames = get(vid, 'NumberOfFrames');
% frameRate = get(vid, 'FrameRate'); %30 frames/sec
% frame = round(numFrames/2);
% figure
% while   1
%     imframe = read(vid, frame);
%     image(imframe)
%     [x,y,k]=ginput(1);
%
%     k;
%     switch k
%         case 29 % arrow right
%             frame = frame +1
%     end
% end
% %             snapframe = read(vid, i);%+vidlag



rec = 1;

timemultiplier = 1.015;
timeshift = 0;
wc_playbackpretime = par.wc_playbackpretime;
%wc_playbackpretime  = 0;
starttime = (wcinfo(rec).stimstart-wc_playbackpretime) * timemultiplier + timeshift;
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