function tpsiegel( filename ,ref_epoch, analysis_epochs, analysis_intervals, frame_period)
%TPSIEGEL wrapper around analyzetpstack for Friederike Siegel
%
%  TPSIEGEL( FILENAME )
%  TPSIEGEL( FILENAME, REF_EPOCH, ANALYSIS_EPOCHS,ANALYSIS_INTERVALS )
%  TPSIEGEL( FILENAME, REF_EPOCH, ANALYSIS_EPOCHS,ANALYSIS_INTERVALS,FRAME_PERIOD )
%
%    FILENAME: Filename of TIF to analyze
%    REF_EPOCH: double of reference epoch number
%    ANALYSIS_EPOCHS: vector of all epochs to analyze
%    ANALYSIS_INTERVALS: [Mx2] matrix of all time intervals in second to
%        consider separately. For instance the period before and after and
%        experimental procedure. Epochs are given artificial starting
%        times, e.g. epoch '07' is starting at t = 7000 s.
%    FRAME_PERIOD: single frame duration in seconds, if not experimental_parameters.xls is unavailable 
%
%  example: tpsiegel('20090626 AMam10/AMam10a15.tif',15,[7:16 18:20 22],[0 15999;16000 Inf]);
%
% 2009, Alexander Heimel
%

if nargin<3
    analysis_epochs = [];
end

if nargin<2
    ref_epoch = '';
end
if isempty(ref_epoch)
    ref_epoch = 1;
end


switch computer % for debugging on Alexander's computer
    case 'GLNX86'
        root = '/home/data/InVivo/Twophoton/Friederike';
    otherwise
        root = 'N:IV05';
end


if nargin<1 || isempty(filename)
    if exist(root,'dir')
        cd(root);
    end
    [fname, fpath ] = uigetfile('*.tif','Load image file');
    if fname == 0
        return
    end
    filename = fullfile( fpath, fname);
    
else
    if ~exist(filename,'file')
        filename = fullfile(root,filename);
        if ~exist(filename,'file')
            error(['Cannot find file ' filename]);
        end
    end
end
[fpath,fname] = fileparts(filename);
%filename = '/home/data/InVivo/Friederike/20090101 AMam21/AMam21a01.tif';


% AMam21a01.tif

record.tpdatapath = fpath; % only for Friederike's data

record.experiment = fname(1:end-5); % Amam
record.stack = fname(end-4:end-3); % 21
record.mouse = fname(end-2); % a
record.epoch = fname(end-1:end); % 01
record.ref_epoch = num2str(ref_epoch,'%02d');
record.setup = 'lohmann';

% parse date
ind = findstr(fpath,'20');
year = fpath(ind:ind+3);
month = fpath(ind+4:ind+5);
day = fpath(ind+6:ind+7);
record.date = [year '-' month '-' day];

record.datatype = 'tp';
record.experimenter = 'FS';
record.slice = '';

% load experimental parameters

if ~exist('frame_period','var')
try
    exppardb = xls2db(fullfile(root,'experimental parameters.xls'),[record.experiment record.stack],4);
    expname = [record.experiment record.stack record.mouse record.epoch];
    ind = find_record(exppardb,['field1=' expname]);
    if isempty(ind)
        warning('TPSIEGEL:could not find experimental parameters');
    else % parse parameters
        exppar = exppardb(ind);
        if ischar(exppar.frameRate)
            record.frame_period = str2double(trim(exppar.frameRate(exppar.frameRate~='s')));
        else
            record.frame_period = exppar.frameRate;
        end

    end
catch
    disp('defaulting to frame duration 0.35');
    record.frame_period =0.356;
end
else
    record.frame_period = frame_period;
end

record

if ~isempty(analysis_epochs)
    analysis_parameters.epochs = num2str(analysis_epochs,'%02d,');
    analysis_parameters.epochs = analysis_parameters.epochs(1:end-1);
    analysis_parameters.timeint = analysis_intervals;
else
    analysis_parameters = [];
end
record
analyzetpstack('NewWindow', record, [], analysis_parameters);
