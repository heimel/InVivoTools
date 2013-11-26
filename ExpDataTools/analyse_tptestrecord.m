function record=analyse_tptestrecord( record)
%ANALYSE_TPTESTRECORD
%
%   RECORD=ANALYSE_TPTESTRECORD( RECORD)
%
% 2013, Alexander Heimel


tpsetup(record);
% if ~exist(tpdatapath(record),'dir')
%     errormsg(['There is no directory ' tpdatapath(record) ]);
%     return
% end
% [filename,record] = tpfilename(record);
% if ~exist(filename,'file')
%     errordlg([filename ' does not exist.']);
%     return
% end


params = tpreadconfig(record);
if isempty(params)
    % keep the possibility for an xyzt or xytz stack
    if isfield(record,'measures') && isfield(record.measures,'response')
        is_movie = true;
        is_zstack = false;
    else
        is_movie = false;
        is_zstack = false;
    end
elseif ~isfield(params,'third_axis_name') || ...
        strcmpi(params.third_axis_name,'z')
    is_movie = false;
    is_zstack = true;
else
    is_movie = true;
    is_zstack = false;
end

process_params = tpprocessparams('',record);
if isempty(record.ROIs)
    record.ROIs.celllist = [];
    record.ROIs.new_cell_index = 1;
end
record.ROIs.celllist = structconvert(record.ROIs.celllist,tp_emptyroirec);

% clean all measures
record.measures = [];

if isfield(record,'ROIs') && isfield(record.ROIs,'celllist')
    n_rois = length(record.ROIs.celllist);
    for i=1:n_rois
        record.measures(i).index = record.ROIs.celllist(i).index;
    end
end


% linking ROIs to lines / neurites
if 1
    record = tp_link_rois( record );
else
    disp('ANALYSE_TPTESTRECORD: temporarily turned off tp_link_rois') %#ok<UNRCH>
end

% compute ROI lengths / circumferences
if is_zstack
    if ~isfield(params,'z_step')
            errordlg(['Image is not a z-stack. ' recordfilter(record)],'Get neurite length.');
    end
    for i=1:n_rois
        record.measures(i).length  = tp_get_neurite_length( record.ROIs.celllist(i), record );
    end
end

% getting intensities
if  process_params.get_intensities
    record = tp_get_intensities(record);
  %  record = tp_get_intensities(record); % run twice for proper normalizations
else
    disp('ANALYSE_TPTESTRECORD: Temporarily turned off get_intensities')  
end


% create measure fields for labels and types
%labels = {tpstacklabels(record),uniq(sort({record.ROIs.celllist.type}));

labels = {};
for i=1:length(record.ROIs.celllist);
    labels = [labels{:},record.ROIs.celllist(i).labels'];
end
labels = uniq(sort(labels));
labels = uniq(sort([tpstacklabels(record) labels]));
types = uniq(sort([tpstacktypes(record),uniq(sort({record.ROIs.celllist.type}))]));
for i=1:n_rois
    record.measures(i).present = logical(record.ROIs.celllist(i).present);
end

disp('ANALYSE_TPTESTRECORD: TEMPORARILY ADDING LABELS FOR ANNEMARIE. CAN GO WHEN SHE HAS GONE.');
for i=1:n_rois
    record.measures(i).labels = record.ROIs.celllist(i).labels;
end


for label = labels
    field = subst_specialchars(lower(label{1}));
    if isempty(field)
        continue
    end
    for i=1:n_rois
        if ismember(label{1},record.ROIs.celllist(i).labels)
            record.measures(i).(field) = true;
        else
            record.measures(i).(field) = false;
        end
    end
    %     if ~any([record.measures(:).(field)])
    %         record.measures = rmfield(record.measures,field);
    %     end
end

% temporary change for 12.81, 2013-05-24
for i=1:n_rois
    switch record.ROIs.celllist(i).type
        case {'spine mushroom','spine stubby','spine thin','filopodium'} 
            record.ROIs.celllist(i).type = 'spine';
    end        
end



for stype = types
    field = subst_specialchars(lower(stype{1}));
    for i=1:n_rois
        if strcmp(stype{1},record.ROIs.celllist(i).type)
            record.measures(i).(field) = true;
        else
            record.measures(i).(field) = false;
        end
    end
    %     if ~any([record.measures(:).(field)])
    %         record.measures = rmfield(record.measures,field);
    %     end
end


if ~isempty(record.slice)
    timepoint = record.slice;
    timepoint( timepoint>='A' & timepoint<='z') = [];
    timepoint = str2double(timepoint);
    if ~isnan(timepoint)
        for i=1:n_rois
            record.measures(i).timepoint = timepoint;
        end
    end
end


% get presence time lapse series
if isfield(record.measures,'present') && ...
    (~isempty(findstr(record.slice,'day')) || ...
    ~isempty(findstr(record.slice,'hour')) || ...
    ~isempty(findstr(record.slice,'minute')))
    series_measures =  process_params.series_measures;
    ref_record = tp_get_refrecord(record,false);
    if ~isempty(ref_record) && isfield(ref_record,'measures') && isfield(ref_record.measures,'present')
        
        for i=1:n_rois
            record.measures(i).gained = NaN;
            record.measures(i).lost = NaN;
            record.measures(i).was_present = NaN;
            
            % gained = 1 if present now, not before,
            % gained = 0 if present now and before
            % gained = NaN if not present now, or first record
            
            % lost = 1 if present before, not now,
            % lost = 0 if present before and now
            % lost = NaN if not present before, or first record
            
            ref_i = find([ref_record.measures.index]==record.measures(i).index);
            if length(ref_i)>1
                msg = ['More than one ROIs with index ' num2str(record.measures(i).index) ...
                    ' in ' recordfilter(ref_record) '. Taking first only.'];
                errordlg(msg,'Analyse tptestrecord');
                disp(['ANALYSE_TPTESTRECORD: ' msg]);
                ref_i = ref_i(1);
            end
            if ~isempty(ref_i)
                if record.measures(i).present
                    record.measures(i).gained =  ~ref_record.measures(ref_i).present;
                end
                if ref_record.measures(ref_i).present
                    record.measures(i).lost = ~record.measures(i).present;
                end
                record.measures(i).was_present = ref_record.measures(ref_i).present;
            else
                record.measures(i).gained = record.measures(i).present;
                record.measures(i).was_present = false;
            end
        end
        
        if isfield(ref_record.measures,'mito_close')
            for i=1:n_rois
                record.measures(i).mito_was_close = NaN;
                ref_i = [ref_record.measures.index]==record.measures(i).index;
                if any(ref_i)
                    record.measures(i).mito_was_close = ref_record.measures(ref_i).mito_close;
                end
            end
            if all(isnan([record.measures.mito_was_close]))
                record.measures = rmfield(record.measures,'mito_was_close');
            end
        end
        
        for measure = series_measures
            measure_series = [measure{1} '_series'];
            if isfield(ref_record.measures,measure_series)
                ref_measure = measure_series;
            elseif isfield(ref_record.measures,measure{1})
                ref_measure = measure{1};
            else
                disp(['ANALYSE_TPTESTRECORD: ' measure{1} ' is not a measure in reference record. Please analyse or edit tpprocessparams series_measures.']);
                continue
            end
            for i=1:n_rois
                ref_i = [ref_record.measures.index]==record.measures(i).index;
                record.measures(i).(measure_series) = [ref_record.measures(ref_i).(ref_measure) record.measures(i).(measure{1})];
            end
        end

        
%         if isfield(record.measures,'present_series')
%             for i=1:n_rois
%                 present = record.measures(i).present_series;
%                 n_timepoints = length(present);
%                 record.measures(i).timepoint_series = 1:n_timepoints;
%                 record.measures(i).n_timepoints = n_timepoints;
%             end
%         end
        
    else
        for i=1:n_rois
            record.measures(i).gained = NaN;
            record.measures(i).lost = NaN;
        end
    end
end

switch record.experiment
    case {'11.21','12.81','Examples'}
        record = tp_get_distance_from_pia( record );
end

if isfield(record,'measures') && isfield(record.measures,'mito') && any([record.measures(:).mito])
    record = tp_mito_close( record );
end

% getting densities
record = tp_analyse_neurites( record );


if is_movie
    record = tp_analyse_movie( record );
    record = add_distance2preferred_stimulus( record );
end



