function dbpath=expdatabasepath( where)
%EXPDATABASEPATH returns database folder
%
% 
% 200X-2015, Alexander Heimel
%

persistent dbpath_network dbpath_local

if nargin<1
    where='network';
end

switch where
    case 'network'
        if ~isempty(dbpath_network)
            dbpath=dbpath_network;
            return
        end
        base=networkpathbase;
    case 'local'
        if ~isempty(dbpath_local)
            dbpath=dbpath_local;
            return
        end
        base = '';
        if isunix
            if ismac
                base = ['/Users/',user,'/Documents/Data/InVivo'];
            else
                base='/home/data/InVivo';
            end
        elseif ispc
            base='C:\Data\InVivo';
        end
        params = processparams_local([]);
        if isfield(params,'databasepath_localroot')
            base = params.databasepath_localroot;
        end
end
dbpath=fullfile(base,'Databases');

if exist(dbpath,'dir')~=7
    switch where
        case 'local'
            logmsg([ dbpath ' does not exist. Defaulting to desktop folder.']);
            dbpath = getdesktopfolder;
        case 'network'
            logmsg([ dbpath ' does not exist. Will try to load local copy']);
            dbpath=expdatabasepath('local');
    end
end

switch where
    case 'local'
        dbpath_local=dbpath;
    case 'network'
        dbpath_network=dbpath;
end

return

