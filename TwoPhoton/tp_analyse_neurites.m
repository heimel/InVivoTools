function record = tp_analyse_neurites( record )
%TP_ANALYSE_NEURITES analyses the neurite ROIs in a tptestrecord
%
%  RECORD = TP_ANALYSE_NEURITES( record )
%
% 2012-2013, Alexander Heimel
%

roilist = record.ROIs.celllist;

ind = find(cellfun(@is_neurite,{roilist.type}));

if isempty(ind)
    return
end

types = tpstacktypes(record);
density_types = {};
for t = types(:)'
   if any( [record.measures.(t{1})])
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
    neuritelength = tp_get_neurite_length( roi, record );
    record.measures(i).length = neuritelength;
    roi.neurite = [roi.index neuritelength ]; % use of length here is deprecated
    roi.extra.length = neuritelength; % use of length here is deprecated
    
    % get puncta density
    neurites = reshape([roilist.neurite],2,length(roilist));
    
    % get puncta
    ind_puncta = find(neurites(1,:)==roi.index);
    ind_puncta = ind_puncta(find_record(roilist(ind_puncta),'present=1'));

    
    record.measures(i).density = length(   find_record(roilist(ind_puncta),'present=1')) / neuritelength;
    for t = density_types(:)'
        field = ['density_' t{1}];
        record.measures(i).(field) = length(   find_record(roilist(ind_puncta),['present=1,type=' t{1}])) / neuritelength;
    end

    % next lines are deprecated 2013-04-17
    roi.extra.density_puncta = length(   find_record(roilist(ind_puncta),'present=1,(type=shaft|type=spine)')) / neuritelength;
    roi.extra.density_shaft = length(   find_record(roilist(ind_puncta),'present=1,type=shaft')) / neuritelength;
    roi.extra.density_spine = length(   find_record(roilist(ind_puncta),'present=1,type=spine')) / neuritelength;
    
    roilist(i) = roi;
end

record.ROIs.celllist = roilist; 