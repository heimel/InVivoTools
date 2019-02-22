function base=localpathbase(vers)
%LOCALPATHBASE return base of local data path
%
% BASE = LOCALPATHBASE(VERS='2004')
%
% 2012-2018, Alexander Heimel
%

persistent vers_pers base_pers

if nargin<1 || isempty(vers)
    vers = '2004';
end

if strcmp(vers_pers,vers)
    base = base_pers;
    return
end   

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

% override by processparams_local
params = processparams_local([]);
if isfield(params,'experimentpath_localroot')
    base = params.experimentpath_localroot;
end
    
if ~exist(base,'dir')
    logmsg(['Folder ' base ' does not exist. Perhaps set params.experimentpath_localroot in processparams_local.m']);
end

base_pers = base;
vers_pers = vers;
