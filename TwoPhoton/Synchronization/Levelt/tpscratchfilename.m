function sfname=tpscratchfilename( records, channel, stype, ext )
%TPFILENAME constructs full scratch filename for tpdata including path
%
%  SFNAME = TPSCRATCHFILENAME( RECORDS, STYPE )
%
%     RECORDS contains experiment description needed to locate the imagefile
%     if RECORDS consist of multiple records, the filename will be based
%     on the first record, except for all the other records epoch fields
%     check HELP TP_ORGANIZATION for detailed explanation of record fields
%     STYPE contains scratch file type (e.g. drift, raw)
%
%     SFNAME contains full path to the image file
%
% 2009, Alexander Heimel

if nargin<4
    ext = '';
end
if isempty(ext)
    ext = '.mat';
end
if ext(1)~='.'
    ext = ['.' ext];
end
if nargin<3
    stype='';
end
if nargin<2
    channel=[];
end

record = records(1);

scratchdir = fullfile(experimentpath(record),'analysis','scratch');%getscratchdirectory( ds, 1);
if ~exist(scratchdir,'dir')
    mkdir(scratchdir);
end
if ~isempty(channel)
    channel=['_ch' int2str(channel)];
end
epochs = [records(:).epoch];
sfname = fullfile(scratchdir, subst_filechars([record.experiment record.stack record.mouse record.slice epochs channel '_' stype ext]));