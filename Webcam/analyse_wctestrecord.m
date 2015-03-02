function record = analyse_wctestrecord( record, verbose )
%ANALYSE_WCTESTRECORD analyses webcam testrecord
%
%  RECORD = ANALYSE_WCTESTRECORD( RECORD, VERBOSE=true )
%
% 2015, Alexander Heimel
% 

if nargin<2
    verbose = [];
end
if isempty(verbose)
    verbose = true;
end

d = dir(fullfile(experimentpath(record),'webcam*info.mat'));
for i = 1:length(d)
    wcinfo(i) = load(fullfile(experimentpath(record),d(i).name))
end
