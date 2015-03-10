function play_wctestrecord(record)
%PLAY_WCTESTRECORD plays webcam movie
%
% 2015, Alexander Heimel

if isunix
    [status,out] = system('which vlc');
    if status==0
        player = 'vlc' ;
    else
        player = 'totem';
    end
else
    errormsg('Do not know which player to use for Windows. Needs to be implemented.');
    return
end

wcinfo = wc_getmovieinfo( record);


rec = 1;
switch player
    case 'vlc'
        player = [ player ' --start-time=' num2str(wcinfo(rec).stimstart)];
end

cmd = [ player ' ' fullfile(    wcinfo(rec).path,wcinfo(rec).mp4name) ];

[status,out] = system(cmd);
%[status,out] = unix([ player ' ' fullfile(    wcinfo(rec).path,wcinfo(rec).mp4name) ]);

status
out