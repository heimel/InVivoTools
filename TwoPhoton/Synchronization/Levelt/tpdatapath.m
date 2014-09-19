function path=tpdatapath( record )
%TPDATAPATH constructs a twophoton data path
%
% PATH = TPDATAPATH( RECORD )
%  by default PATH is the networkpath, unless a local data folder is
%  present
%
% check TP_ORGANIZATION for organization of the files
%
% 2008-2014, Alexander Heimel
%

data_name = 'Twophoton';

% set default root
params.tpdatapath_networkroot = fullfile(networkpathbase ,data_name);

if ispc
    localbase = 'C:';
elseif isunix
    localbase = '/home';
elseif ismac
    localbase = '/Users';
end

params.tpdatapath_localroot = fullfile(localbase,'data','InVivo',data_name);
if ~exist(params.tpdatapath_localroot,'dir')
    params.tpdatapath_localroot = fullfile(localbase,'data');
end

% check for local overrides
params = processparams_local(params);

if ~exist(params.tpdatapath_localroot,'dir') % fall back on current folder
    params.tpdatapath_localroot = '.';
end

if nargin==1
    if isempty(record.mouse)
        warning('TPDATAPATH:NO_MOUSE_NUMBER','Record does not contain mouse number, e.g. 08.26.1.06');
        warning('OFF','TPDATAPATH:NO_MOUSE_NUMBER');
    end
    if isempty(record.date)
        warning('TPDATAPATH:NO_EXPERIMENT_DATE','Record does not contain experiment date, e.g. 2010-05-19');
        warning('OFF','TPDATAPATH:NO_EXPERIMENT_DATE');
    end
    
    % first try local root
    path=fullfile(params.tpdatapath_localroot,record.experiment,record.mouse,record.date,record.epoch);
    if ~exist(path,'dir')
        path=fullfile(params.tpdatapath_networkroot,record.experiment,record.mouse,record.date,record.epoch);
        if ~exist(path,'dir')
            % fall back to local path
            path=fullfile(params.tpdatapath_localroot,record.experiment,record.mouse,record.date,record.epoch);
        end       
    end        
else
    path=params.tpdatapath_localroot;
    if ~exist(path,'dir')
        path=params.tpdatapath_networkroot;
        if ~exist(path,'dir')
            path=params.tpdatapath_localroot;
        end
    end
end


