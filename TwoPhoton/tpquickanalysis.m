function tpquickanalysis( filename ,ref_epoch, analysis_epochs, analysis_intervals)
%TPQUICKANALYSIS wrapper around analyzetpstack 
%
%  TPQUICKANALYSIS( FILENAME )
%  TPQUICKANALYSIS( FILENAME, REF_EPOCH, ANALYSIS_EPOCHS,ANALYSIS_INTERVALS )
%
%    FILENAME: Filename of TIF to analyze
%    REF_EPOCH: double of reference epoch number
%    ANALYSIS_EPOCHS: vector of all epochs to analyze
%    ANALYSIS_INTERVALS: [Mx2] matrix of all time intervals in second to
%        consider separately. For instance the period before and after and
%        experimental procedure. Epochs are given artificial starting
%        times, e.g. epoch '07' is starting at t = 7000 s.
%
%  example: tpquickanalysis('D:\Data\08.26\08.26.1.05\2010-04-23\Live_0001XYT3min.tif')
%    
% 2010, Alexander Heimel, based on TPSIEGEL
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
    case {'GLNX86','GLNXA64'}
        root = '/home/data/InVivo/Twophoton';
    otherwise
        root = 'D:\Data';
end


if nargin<1 || isempty(filename)
    if exist(root,'dir')
        cd(root);
    end
    [fname, fpath ] = uigetfile('*.tif','Load image file');
    if fname == 0
        return
    end
else
    [fpath,fname,fext] = fileparts(filename);
    fname=[fname fext];
end
%filename = '/home/data/InVivo/Friederike/20090101 AMam21/AMam21a01.tif';




% AMam21a01.tif

ind = findstr(fpath=='.',1);
record.experiment = fpath(ind-2:ind+2); 
record.mouse = fpath(ind+4:ind+2+find(fpath(ind+4:end)==filesep,1));


record.stack = fname(1:end-4);

record.epoch = 't00001'; %fname(8:9); % 01
record.ref_epoch = 't00001'; %num2str(ref_epoch,'%02d');

% parse date
ind = findstr(fpath,'20');
year = fpath(ind:ind+3);
month = fpath(ind+5:ind+6);
day = fpath(ind+8:ind+9);
record.date = [year '-' month '-' day];

record.datatype = 'tp';
record.experimenter = '';
record.slice = '';

% load experimental parameters

record

if ~isempty(analysis_epochs)
    analysis_parameters.epochs = num2str(analysis_epochs,'%02d,');
    analysis_parameters.epochs = analysis_parameters.epochs(1:end-1);
    analysis_parameters.timeint = analysis_intervals;
else
    analysis_parameters = [];
end

analyzetpstack('NewWindow', record, [], analysis_parameters);
