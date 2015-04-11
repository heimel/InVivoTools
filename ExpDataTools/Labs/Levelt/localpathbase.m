function base=localpathbase(vers)
%LOCALPATHBASE return base of local data path
%
% BASE = LOCALPATHBASE(VERS='2004')
%
% 2012-2015, Alexander Heimel
%

if nargin<1 || isempty(vers)
    vers = '2004';
end

switch vers
    case '2004'
        if ispc % i.e. windows
            base = 'D:\Data\InVivo';
            if ~exist(base,'dir')
                base = 'C:\Data\InVivo';
            end
        elseif ismac
            base = '/Users/user/Dropbox/Data';
        else % linux
            base = '/home/data/InVivo';
        end
    case '2015'
        base = fullfile('home',user,'Dropbox');
end
    
if ~exist(base,'dir')
    logmsg(['Folder ' base ' does not exist.']);
end

  