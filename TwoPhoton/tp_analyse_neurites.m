function record = tp_analyse_neurites( record,params )
%TP_ANALYSE_NEURITES analyses the neurite ROIs in a tptestrecord
%
%  RECORD = TP_ANALYSE_NEURITES( record )
%
% 2012-2015, Alexander Heimel
%

if nargin<2 
    params = [];
end

roilist = record.ROIs.celllist;

ind = find(cellfun(@is_neurite,{roilist.type}));

if isempty(ind)
    return
end

types = tpstacktypes(record);
density_types = {};
for t = types(:)'
   if isfield(record.measures,t{1}) && any( [record.measures.(t{1})])
      density_types{end+1} = t{1};
   end
end


for i=1:length(roilist)
    if ~isfield(record.measures,'length')
        record.measures(i).length = NaN;
    end
    record.measures(i).density = NaN; % anything linked

    for t = density_types(:)'
        field = ['density_' t{1}];
        record.measures(i).(field) = NaN;
    end
end

for i = ind % neurites
    roi = roilist(i);
    
    % get length
    neuritelength = tp_get_neurite_length( roi, record,params );
    record.measures(i).length = neuritelength;
    roi.neurite = [roi.index neuritelength ]; % use of length here is deprecated
    
    % get present puncta 
    neurites = cellfun(@(x) x(1),{roilist.neurite});
    ind_puncta = find(neurites==roi.index & [roilist.present]==1);
    
    record.measures(i).density = length(ind_puncta) / neuritelength;
    for t = density_types(:)'
        record.measures(i).(['density_' t{1}]) = length(   find_record(roilist(ind_puncta),['type=' t{1}])) / neuritelength;
    end

    roilist(i) = roi;
end

record.ROIs.celllist = roilist; 