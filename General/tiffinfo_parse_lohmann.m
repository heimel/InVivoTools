function tinf = tiffinfo_parse_lohmann(tinf)
%TIFFINFO_PARSE_LOHMANN used by tiffinfo for lohmannlab scope metadata
%
% TINF = TIFFINFO_PARSE_LOHMANN( TINF )
%   adds the following fields to TINF struct:
%       NumberOfFrames
%       Scan_direction
%
% 2012, Alexander Heimel
%

tinf(1).Scan = str2num(tinf(1).ParsedImageDescription.scan);  %#ok<ST2NM>
% compute scan direction. Not extensively tested
scanx = tinf(1).Scan(find(tinf(1).Scan(:,3)==3,2),4);
scany = tinf(1).Scan(find(tinf(1).Scan(:,3)==4,2),4);
tinf(1).Scan_direction = cart2pol(scanx(2),scany(2))/pi*180;
if isfield( tinf(1).ParsedImageDescription, 'slices')
    tinf(1).NumberOfFrames = tinf(1).ParsedImageDescription.slices;
else
    tinf(1).NumberOfFrames = length(tinf);
end
return

