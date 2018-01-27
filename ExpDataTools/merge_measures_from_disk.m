function measures = merge_measures_from_disk(record)
%MERGE_MEASURES_FROM_DISK loads measures from disk and merges with record
%
%  MEASURES = MERGE_MEASURES_FROM_DISK( RECORD )
%
% 2014, Alexander Heimel
%

measures_on_disk = []; 

measuresfile = fullfile(experimentpath(record),[record.datatype '_measures.mat']);

if exist(measuresfile ,'file')
    load(measuresfile);
    if exist('measures','var')
        measures_on_disk = measures; %#ok<NODEF>
    else
        measures_on_disk = [];
    end
end

measures = record.measures;
if ~isempty(measures_on_disk) && length(measures_on_disk)==length(measures)
    if isstruct(measures)
        f = fieldnames(measures);
    else
        f = {};
    end
    if isstruct(measures_on_disk)
        f_on_disk = fieldnames(measures_on_disk);
    else
        f_on_disk = {};
    end
    sf = intersect(setdiff(f_on_disk,f),f_on_disk);
    for i = 1:length(measures)
        for f = 1:length(sf)
            measures(i).(sf{f}) = measures_on_disk(i).(sf{f});
        end
    end
end

