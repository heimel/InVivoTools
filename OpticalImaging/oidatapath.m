function datapath=oidatapath( record )
%OIDATAPATH constructs path to data from optical imaging record
%
%   DATAPATH = OIDATAPATH( RECORD )
%   used from RECORD are fields DATE and SETUP
%
% DEPRECATED: Use EXPERIMENTPATH instead
%
% 2009-2013, Alexander Heimel
%

if nargin<1
    record.setup = 'andrew';
    record.date = datestr(now,'yyyy/mm/dd');
end

switch lower(record.setup)
    case {'andrew','daneel','jander'}
        % do nothing
    otherwise
        logmsg(['Unknown imaging setup [' record.setup ']']);
end

% construct pathend
if isfield(record,'date')
    pathend=record.date;
    pathend(pathend=='-')=filesep;
    switch lower(record.setup)
        case 'andrew'
            pathend(end+1)='a';
    end
else
    pathend = '';
end

% first specify local root
switch host
    case {'daneel','andrew'}
        if isunix
            base = '/home/data';
        else
            base = 'D:\Data';
        end
    case 'jander'
        if isunix
            base = '/home/data';
        else
            base = 'C:\Data';
        end
        base = fullfile(base,'InVivo','Imaging',capitalize(host));
    otherwise
        if isunix
            base = '/home/data';
        else
            base = 'C:\Data';
        end
        base = fullfile(base,'InVivo','Imaging',capitalize(record.setup));
end

% first check locally
params.oidatapath_localroot = base;

% check for local overrides
params = processparams_local(params);

datapath=fullfile(params.oidatapath_localroot,pathend);

if ~exist(datapath,'dir')
    if isfield(record,'date')  % construct pathend
        oldpathend = record.date;
        switch lower(record.setup)
            case 'andrew'
                oldpathend(end+1)='a';
        end
    else
        oldpathend = '';
    end
    
    datapath = fullfile(params.oidatapath_localroot,oldpathend);
    if ~exist(datapath,'dir')
        datapath = fullfile(networkpathbase,'Imaging',capitalize(record.setup),pathend);
    end
end
if ~exist(datapath,'dir')
    logmsg(['Could not find data directory ' datapath ]);
end

