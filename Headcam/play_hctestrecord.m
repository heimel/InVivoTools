function play_hctestrecord( record, verbose)
%PLAY_HCTESTRECORD analyses headcamera test record
%
% PLAY_HCTESTRECORD( RECORD, VERBOSE)
%
% 2021, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

hc_trackpupil(record,[],verbose);


