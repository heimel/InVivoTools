function fname = tpfilename( record, frame, channel, image_processing ) 
%TPFILENAME constructs full image filename for tpdata
%
%  FNAME = TPFILENAME( RECORD, FRAME, CHANNEL )
%
%     RECORD contains experiment description needed to locate the imagefile
%     check HELP TP_ORGANIZATION for detailed explanation of record fields
%
%     FNAME contains full path to the image file
%
% 2009-2011, Alexander Heimel
%

if nargin<4 
    image_processing = [];
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

switch host
    case 'nin158' % friederike
        fname = fullfile( tpdatapath( record ),processed,[record.experiment record.stack record.mouse record.epoch optcode '.tif']);
    otherwise % juliette
        fname = fullfile( tpdatapath(record),processed, [record.mouse record.stack record.epoch optcode '.tif']);
end
