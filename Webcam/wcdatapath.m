function path=wcdatapath( record, create )
%WCDATAPATH constructs a twophoton data path
%
% PATH = WCDATAPATH( RECORD )
%  by default PATH is the networkpath, unless a local data folder is
%  present
%
% DEPRECATED: Use EXPERIMENTPATH instead
%
% 2014-2015, Alexander Heimel
%

path = pwd;

if nargin<2
    create = [];
end
if isempty(create)
    create = false;
end
if nargin<1
    record = [];
end

if isempty(record)
    errormsg('Cannot return path for empty record');
    dbstack
    return
end

% set default root
params.wcdatapath_networkroot = fullfile(networkpathbase ,'Experiments');
params.wcdatapath_localroot = fullfile(localpathbase,'Experiments');

% check for local overrides
params = processparams_local(params);



branch = fullfile(record.experiment,record.mouse,record.date,record.setup,record.epoch);

% first try local root
path=fullfile(params.wcdatapath_localroot,branch);

if ~exist(path,'dir')
    path = fullfile(params.wcdatapath_networkroot,branch);
    if ~exist(path,'dir')  % fall back to local path
        path = fullfile(params.wcdatapath_localroot,branch);
    end
end

if ~exist(path,'dir') 
    if create
        mkdir(path);
    else 
        path = '.';
    end
end