function path=wcdatapath( record )
%WCDATAPATH constructs a twophoton data path
%
% PATH = WCDATAPATH( RECORD )
%  by default PATH is the networkpath, unless a local data folder is
%  present
%
% 2014, Alexander Heimel
%

data_name = 'Webcam';

% set default root
params.wcdatapath_networkroot = fullfile(networkpathbase ,data_name);

if ispc
    localbase = 'C:';
elseif isunix
    localbase = '/home';
elseif ismac
    localbase = '/Users';
end

params.wcdatapath_localroot = fullfile(localbase,'data','InVivo');
if ~exist(params.wcdatapath_localroot,'dir')
    params.wcdatapath_localroot = fullfile(localbase,'data');
end

% check for local overrides
params = processparams_local(params);

if ~exist(params.wcdatapath_localroot,'dir') % fall back on current folder
    params.wcdatapath_localroot = '.';
end

if nargin==1
    if isempty(record.mouse)
        warning('WCDATAPATH:NO_MOUSE_NUMBER','Record does not contain mouse number, e.g. 08.26.1.06');
        warning('OFF','WCDATAPATH:NO_MOUSE_NUMBER');
    end
    if isempty(record.date)
        warning('WCDATAPATH:NO_EXPERIMENT_DATE','Record does not contain experiment date, e.g. 2010-05-19');
        warning('OFF','WCDATAPATH:NO_EXPERIMENT_DATE');
    end
    
    % first try local root
    branch = fullfile(record.experiment,record.mouse,record.date,record.setup,record.epoch);
    
    path=fullfile(params.wcdatapath_localroot,branch);
    if ~exist(path,'dir')
        path=fullfile(params.wcdatapath_networkroot,branch);
        if ~exist(path,'dir')  % fall back to local path
            path=fullfile(params.wcdatapath_localroot,branch);
        end       
    end        
else
    path=params.wcdatapath_localroot;
    if ~exist(path,'dir')
        path=params.wcdatapath_networkroot;
        if ~exist(path,'dir')
            path=params.wcdatapath_localroot;
        end
    end
end


