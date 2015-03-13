function base=localpathbase
%LOCALPATHBASE return base of local data path
%
% BASE = LOCALPATHBASE
%
%  LEVELTLAB dependent, returns path to levelt storage share 
%
% 2012, Alexander Heimel
%

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
    
if ~exist(base,'dir')
    disp(['LOCALPATHBASE: Folder ' base ' does not exist.']);
end

  