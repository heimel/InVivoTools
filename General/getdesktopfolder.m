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
    userdir= getenv('USERPROFILE');
else
    userdir= getenv('HOME');
end
p = fullfile( userdir,'Desktop');
if ~exist(p,'dir')
    p = '.';
    warning('GETDESKTOPFOLDER:NONE_FOUND','Could not find user Desktop folder');
end