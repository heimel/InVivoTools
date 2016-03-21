function p = getdesktopfolder
%GETDESKTOPFOLDER returns user's desktop folder
%
%  P = GETDESKTOPFOLDER
%     returns desktop folder. If it cannot find it,
%     it returns '.', i.e. the current path
%
% 2012, Alexander Heimel
%

if ispc
    try
        p = winqueryreg('HKEY_CURRENT_USER','Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders','Desktop');
    catch me
        logmsg(me.message);
        userdir= getenv('USERPROFILE');
        p = fullfile( userdir,'Desktop');
    end
else
    userdir= getenv('HOME');
    p = fullfile( userdir,'Desktop');
end
if ~exist(p,'dir')
    p = '.';
    warning('GETDESKTOPFOLDER:NONE_FOUND','Could not find user Desktop folder');
end