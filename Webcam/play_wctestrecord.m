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

rec = 1;
starttime = (wcinfo(rec).stimstart-par.wc_playbackpretime) * 1.015;
cmd = par.wc_playercommand;
switch par.wc_player
    case 'vlc'
        cmd = [ cmd ' --start-time=' num2str(starttime)];
end

cmd = [ cmd ' ' fullfile(    wcinfo(rec).path,wcinfo(rec).mp4name) ];

switch par.wc_player
    case 'vlc'
        logmsg('Press ''p'' to replay.');
end

[status,out] = system(cmd);

out