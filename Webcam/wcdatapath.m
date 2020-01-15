function path=wcdatapath( record, create, verbose )
%WCDATAPATH constructs a twophoton data path
%
% PATH = WCDATAPATH( RECORD, CREATE=false, VERBOSE=false )
%  by default PATH is the networkpath, unless a local data folder is
%  present
%
% DEPRECATED: Use EXPERIMENTPATH instead
%
% 2014-2019, Alexander Heimel
%

path = pwd;

if nargin<3 || isempty(verbose)
    verbose = false;
end
if nargin<2 || isempty(create)
    create = false;
end
if nargin<1 || isempty(record)
    errormsg('Cannot return path for empty record');
    dbstack
    return
end

% set default root
params.wcdatapath_networkroot = [networkpathbase filesep 'Experiments']; % much faster than fullfile
params.wcdatapath_localroot = [localpathbase filesep 'Experiments'];% much faster than fullfile

% check for local overrides
params = processparams_local(params);

branch = fullfile(record.experiment,record.mouse,record.date,record.setup,record.epoch);

% first try local root
path=fullfile(params.wcdatapath_localroot,branch);

if ~exist(path,'dir')
    if verbose
        logmsg(['Check params.wcdatapath_localroot in processparams_local. Not existing folder ' path]);
    end
    path = fullfile(params.wcdatapath_networkroot,branch);
    if ~exist(path,'dir')  % fall back to local path
        if verbose
            logmsg(['Check params.wcdatapath_networkroot in processparams_local. Not existing folder ' path]);
        end
        path = fullfile(params.wcdatapath_localroot,branch);
    end
end

if ~exist(path,'dir') 
    if create
        mkdir(path);
    else
        logmsg(['Not existing folder ' path]);
    end
end