function s = tpsetup( inp )
%TPSETUP returns or sets current two-photon setup
%
%  S = TPSETUP( SETUP )
%  S = TPSETUP( RECORD )
%
% 2008-2011, Alexander Heimel
%

persistent cursetup

fp = fileparts(which('tpreadframe.m'));
s = fp( (find(fp==filesep,1,'last')+1):end);
if nargin<1
    % i.e. only query
    return
end

if isstruct( inp ) % assume record
    setup = inp.setup;
else
    setup = inp; % assume string
end

switch lower(setup)
    case {'lif','leica'}
        setup = 'LIF';
    case 'lohmann'
        setup = 'Lohmann';
    case 'dezeeuw'
        setup = 'DeZeeuw';
    case 'scanimage'
        setup = 'ScanImage';
    case 'imagej'
        setup = 'ImageJ';
    otherwise
        setup = 'FluoView';
end

if strcmp(cursetup,setup)
    return
else
    cursetup = setup;
end

% set path
newdir = fullfile( fp( 1:(find(fp==filesep,1,'last'))),setup);
if exist(newdir,'dir')
    rmpath(fp);
    addpath( newdir);
    s = setup;
else
    warning('TPSETUP:UNKNOWN_SETUP',['TPSETUP: Unknown setup ' setup ]);
end