function dbpath=expdatabasepath( where)
%EXPDATABASEPATH returns database folder
% -2013, Alexander Heimel
%


persistent dbpath_network dbpath_local

if nargin<1
    where='network';
end
comp=computer;

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
%        switch comp
%            case {'GLNX86','LNX86'}
%                base='/home/data/InVivo';
%            case {'PCWIN','PCWIN64'}
%                base='C:\Data\InVivo';
%            case {'MACI64','MACI'}
%               base = ['/Users/',user,'/Dropbox'];
%        end
	if isunix
        	base='/home/data/InVivo';
	elseif ispc	
                base='C:\Data\InVivo';
	elseif ismac 
                base = ['/Users/',user,'/Dropbox'];
	else
		logmsg('Unknown operating system');
		base = '';
	end


end
dbpath=fullfile(base,'Databases');

if exist(dbpath,'dir')~=7
    switch where
        case 'local'
            disp(['EXPDATABASEPATH:' dbpath ' does not exist.']);
            dbpath = getdesktopfolder;
            disp(['EXPDATABASEPATH: Defaulting to desktop folder.']);
        case 'network'
            beep;
            disp(['EXPDATABASEPATH:' dbpath ' does not exist. Will try to load local copy']);
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

% % For use of Dropbox
% switch computer
%     case {'GLNX86','LNX86'}
%         dbpath='/mnt/Databases';
%     case {'PCWIN','PCWIN64'}
%         dbpath='C:\Dropbox\Databases';
%     case {'MACI64'}
%         dbpath = '/mnt/Databases';
% end
% disp(['EXPDATABASEPATH: Databases supposed to reside at ' dbpath ]);
% if ~exist(dbpath,'dir')
%     dbpath = getdesktopfolder;
%     disp(['EXPDATABASEPATH: Database folder does not exist. Defaulting to desktop.' ]);
% end
% 
% return
