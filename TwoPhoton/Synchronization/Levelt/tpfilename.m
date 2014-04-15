function [fname,record] = tpfilename( record, frame, channel, image_processing)
%TPFILENAME constructs full image filename for tpdata
%
%  [FNAME,RECORD] = TPFILENAME( RECORD, FRAME, CHANNEL, IMAGE_PROCESSING )
%
%     RECORD contains experiment description needed to locate the imagefile
%     check HELP TP_ORGANIZATION for detailed explanation of record fields
%
%     FNAME contains full path to the image file taking for TPDATAPATH
%     RECORD could be filled by TFILENAME with some default parameters
%
% 2009-2012, Alexander Heimel

if nargin<4
    image_processing = [];
end
if nargin<3
    channel = [];
end
if nargin<2
    frame = [];
end

optcode = '';
processed = '';
if ~isempty( image_processing )
    if image_processing.unmixing == 1
        optcode = [optcode '_um' ];
        processed = 'processed';
    end
    if image_processing.spatial_filter == 1
        optcode = [optcode '_sf' ];
        processed = 'processed';
    end
end

% cut of possible extension for stackname
if strcmpi(record.stack(max(1,end-3):end),'.tif')
    record.stack = record.stack(1:end-4);
end

[fmiddle,ext] = tpfilename_setupdependent(record,frame,channel);


if ~isempty(record.stack)
    fname = getfname( record,processed,fmiddle,optcode,ext);
else
    record.stack = 'Live_0000'; % default Fluoview name
    fname = getfname( record,processed,fmiddle,optcode,ext);
    if exist(fname,'file')
        disp('TPFILENAME: Using default fluoview name Live_0000.tif');
    else
        record.stack = 'Live_0001'; % default Fluoview name
        fname = getfname( record,processed,fmiddle,optcode,ext);
        if exist(fname,'file')
            disp('TPFILENAME: Using default fluoview name Live_0001.tif');
        else 
            record.stack = '';
            fname = getfname( record,processed,fmiddle,optcode,ext);
        end
    end
end


function fname = getfname( record,processed,fmiddle,optcode,ext)
stack = record.stack;
if strcmpi(stack(end-length(ext)+1:end),ext)
    ext = stack(end-length(ext)+1:end); % case could be different from org ext
    stack = stack(1:end-length(ext));
end

fname = fullfile( tpdatapath( record ),processed,...
    [stack fmiddle optcode ext]);


