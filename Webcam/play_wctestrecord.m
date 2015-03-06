function play_wctestrecord(record)
%PLAY_WCTESTRECORD plays webcam movie
%
% 2015, Alexander Heimel

if isunix
    player = 'totem';
else
    errormsg('Do not know which player to use for Windows. Needs to be implemented.');
    return
end

wcinfo = wc_getmovieinfo( record);

rec = 1;
[status,out] = system([ player ' ' fullfile(    wcinfo(rec).path,wcinfo(rec).mp4name) ]);