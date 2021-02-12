function [db,filename,perm,lockfile]=open_db( filename, loadpath, filter)
%OPEN_DB loads matlab struct array database
%
% [DB, FILENAME, PERM, LOCKFILE] = OPEN_DB( FILENAME, LOADPATH, FILTER)
%        all arguments are optional
%
%  LOADPATH is only used if FILENAME is empty
%
%
% 2007-2011, Alexander Heimel
%

% for Windows novell network connections
warning('off','MATLAB:dispatcher:pathWarning');


if nargin<3 || isempty(filter)
    filter = {'*.mdb;*.mat','All databases (*.mat, *.mdb)';...
        '*.mat','MATLAB databases (*.mat)';...
        '*.mdb','MS Access databases (*.mdb)'};
end
if nargin<2 || isempty(loadpath)
  loadpath = pwd;
end
if nargin<1
    filename = '';
end
  
curpath = pwd; % save working directory
				
if ~isempty(filename)
  [loadpath,name,ext] = fileparts(filename);
  if ~isempty(loadpath) && loadpath(1)~='.' % i.e not in the current folder and not relative path
      cd(loadpath);
  end
else
  cd(loadpath);
  [filename,pathname] = uigetfile(filter,'Load database');
  if isnumeric(filename) % i.e. unsuccessful
      db = [];
      filename = 0;
      perm = [];
      lockfile = [];
      return
  end
  filename = fullfile(pathname,filename);
end

[res,lockfile,button] = setlock(filename);
if res==0 
  switch button
      case 'Open read-only'
          logmsg(['Cannot get lock on ' filename '. Opening as READ-ONLY']);
          perm = 'ro';
      case 'Cancel'
          db = [];
          filename = 0;
          perm = [];
          lockfile = [];
          return
  end
else
  perm='rw';
end

if exist(filename,'file')~=2
	logmsg(['Unable to open ' filename ': No such file']);
	db = [];
else
    [dummy1,dummy2,ext] = fileparts(filename);
    switch lower(ext)
        case '.mdb'
            table='Mouse list';
            crit = [];
             db = import_mdb( filename, table, crit );
        otherwise % 'mat' and default
            x = load(filename,'-mat');
            db = x.db;
    end
end

cd(curpath); % change back to working directory
