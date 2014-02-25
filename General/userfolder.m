function p = userfolder
%USERFOLDER returns user's home folder
%
%  P = USERFOLDER
%     returns user's home folder. If it cannot find it,
%     it returns '.', i.e. the current path
%
%  cf. USERPATH
%
% 2014, Alexander Heimel
%

if ispc
    userdir= getenv('USERPROFILE');
else
    userdir= getenv('HOME');
end
p = fullfile( userdir);
if ~exist(p,'dir')
    p = '.';
    warning('USERFOLDER:NONE_FOUND','Could not find user folder');
end