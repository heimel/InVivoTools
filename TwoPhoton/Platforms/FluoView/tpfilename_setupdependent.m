function [fmiddle,ext] = tpfilename_setupdependent( record, frame, channel ) %#ok<INUSD>
%FLUOVIEW/TPFILENAME_SETUPDEPENDENT
%
% [MIDDLE,EXT] = TPFILENAME_SETUPDEPENDENT( RECORD )
%     called by TPFILENAME
%   
% 2012, Alexander Heimel
%

fmiddle = '';

switch lower(record.setup)
    case 'lif'
        ext = '.lif';
    otherwise
        ext = '.tif';
end
