function [record,measures]=analyse_tptestrecord( record, verbose)
%ANALYSE_TPTESTRECORD
%
%   [RECORD,MEASURES] = ANALYSE_TPTESTRECORD( RECORD, VERBOSE)
%
%      MEASURES contains full measures (including PSTHs)
%
% 2013-2018, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

logmsg(['Analyzing ' recordfilter(record)]);

tpsetup(record);

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

process_params = tpprocessparams(record);
if isempty(record.ROIs)
    record.ROIs.celllist = [];
    record.ROIs.new_cell_index = 1;
end
record.ROIs.celllist = structconvert(record.ROIs.celllist,tp_emptyroirec);

% clean all measures, but save some in case we don't have the tiffs locally
if isfield(record,'measures')
    storedmeasures = record.measures;
else
    storedmeasures = [];
end
record.measures = [];

if isfield(record,'ROIs') && isfield(record.ROIs,'celllist')
    n_rois = length(record.ROIs.celllist);
    for i=1:n_rois
        record.measures(i).index = record.ROIs.celllist(i).index;
    end
end

% compute distances of ROIs to lines / neurites, do not relink
if is_zstack 
    record = tp_link_rois( record, false );
end

% compute ROI lengths / circumferences
if is_zstack
    if isempty(params)
        logmsg(['Cannot read image information and can thus not compute lengths. ' recordfilter(record)] );
        if n_rois == length(storedmeasures) && isfield(storedmeasures,'length')
            for i=1:n_rois
                record.measures(i).length  = storedmeasures(i).length;
            end
        end
    else
        if ~isfield(params,'z_step')
            errormsg(['Image is not a z-stack. ' recordfilter(record)]);
        end
        for i=1:n_rois
            record.measures(i).length  = tp_get_neurite_length( record.ROIs.celllist(i), record, params );
        end
    end
end

% getting intensities
if  process_params.get_intensities  && is_zstack
    record = tp_get_intensities(record,verbose);
end

% create measure fields for labels and types
labels = {};
for i=1:length(record.ROIs.celllist)
    labels = [labels{:},record.ROIs.celllist(i).labels'];
end
labels = uniq(sort(labels));
labels = uniq(sort([tpstacklabels(record) labels]));
types = uniq(sort([tpstacktypes(record),uniq(sort({record.ROIs.celllist.type}))]));
for i=1:n_rois
    record.measures(i).present = logical(record.ROIs.celllist(i).present);
end

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

if isfield(record,'measures') && isfield(record.measures,'mito') && any([record.measures(:).mito])
    record = tp_mito_close( record );
end

if isfield(record,'measures') && isfield(record.measures,'bouton') && any([record.measures(:).bouton]) && isfield(record.measures,'t_bouton')
    record = tp_automated_bouton_analysis( record );
    record = tp_bouton_close( record );
end


% get presence time lapse series
if isfield(record.measures,'present') && ...
        (~isempty(strfind(record.slice,'day')) || ...
        ~isempty(strfind(record.slice,'hour')) || ...
        ~isempty(strfind(record.slice,'minute')))
    series_measures =  process_params.series_measures;
    ref_record = tp_get_refrecord(record,false);
    if ~isempty(ref_record) && ischar(ref_record.reliable)
        ref_record.reliable = str2num(ref_record.reliable); %#ok<ST2NM>
    end
    if ~isempty(ref_record) && ~isempty(ref_record.reliable) && ~ref_record.reliable
        logmsg(['Reference record unreliable thus cannot compute gained and lost: ' recordfilter(ref_record)]);
        for i=1:n_rois
            record.measures(i).gained = NaN;
            record.measures(i).lost = NaN;
            record.measures(i).was_present = NaN;
            record.measures(i).persistent = NaN;
        end
    elseif ~isempty(ref_record) && (isempty(ref_record.reliable) || ref_record.reliable)  && ...
            isfield(ref_record,'measures') && isfield(ref_record.measures,'present')
        for i=1:n_rois
            record.measures(i).gained = NaN;
            record.measures(i).lost = NaN;
            record.measures(i).was_present = NaN;
            record.measures(i).changed = NaN;
            record.measures(i).persistent = NaN;
            
            % gained = 1 if present now, not before,
            % gained = 0 if present now and before
            % gained = NaN if not present now, or first record
            
            % lost = 1 if present before, not now,
            % lost = 0 if present before and now
            % lost = NaN if not present before, or first record
            
            % was_present = 1 if present before
            % was_present = 0 if not present before
            % was_present = NaN if first record
            
            % changed = 1 if present now, not before
            % changed = 1 if present before, not now
            % changed = 0 if present now and before
            % changed = 0 if not present now and not before
            % changed = NaN if first record
            
            % persistent = 1 if present now and (persistent before, or first record)
            % persistent = 0 if otherwise 
            
            ref_i = find([ref_record.measures.index]==record.measures(i).index);
            if length(ref_i)>1
                msg = ['More than one ROIs with index ' num2str(record.measures(i).index) ...
                    ' in ' recordfilter(ref_record) '. Taking first only.'];
                errormsg(msg);
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
                record.measures(i).changed = (ref_record.measures(ref_i).present ~= record.measures(i).present);
                if isfield(ref_record.measures(ref_i),'persistent')
                    if isnan(ref_record.measures(ref_i).persistent)
                        record.measures(i).persistent = NaN;
                    else
                        record.measures(i).persistent = (ref_record.measures(ref_i).persistent & record.measures(i).present);
                    end
                else
                    record.measures(i).persistent = NaN; % analysis should be run twice, the first time
                end
            else
                record.measures(i).gained = record.measures(i).present;
                record.measures(i).was_present = false;
                record.measures(i).changed = record.measures(i).present;
                record.measures(i).persistent = NaN;
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
        
        if isfield(ref_record.measures,'bouton_close')
            for i=1:n_rois
                record.measures(i).bouton_was_close = NaN;
                ref_i = [ref_record.measures.index]==record.measures(i).index;
                if any(ref_i)
                    record.measures(i).bouton_was_close = ref_record.measures(ref_i).bouton_close;
                end
            end
            if all(isnan([record.measures.bouton_was_close]))
                record.measures = rmfield(record.measures,'bouton_was_close');
            end
        end
        
        for measure = series_measures
            measure_series = [measure{1} '_series'];
            if isfield(ref_record.measures,measure_series)
                ref_measure = measure_series;
            elseif isfield(ref_record.measures,measure{1})
                ref_measure = measure{1};
            else
                warning(['ANALYSE_TPTESTRECORD:NO_' subst_specialchars(measure{1})], [measure{1} ' is not a measure in reference record. Please analyse or edit tpprocessparams series_measures.']);
                warning('off',['ANALYSE_TPTESTRECORD:NO_' subst_specialchars(measure{1})]);
                continue
            end
            for i=1:n_rois
                ref_i = [ref_record.measures.index]==record.measures(i).index;
                record.measures(i).(measure_series) = [ref_record.measures(ref_i).(ref_measure) record.measures(i).(measure{1})];
            end
        end
        
    else % assume first record in series
        for i=1:n_rois
            record.measures(i).gained = NaN;
            record.measures(i).lost = NaN;
            record.measures(i).was_present = NaN;
            if record.measures(i).present 
                record.measures(i).persistent = true;
            else
                record.measures(i).persistent = NaN;
            end
        end
    end
end

if is_zstack
    switch record.experiment
        case {'11.21','12.81','Examples'}
            record = tp_get_distance_from_pia( record );
    end
end

% getting densities
if isempty(params)
    if ~process_params.tp_mumble_not_present
        errormsg(['Cannot read image information and can thus not compute analyse neurites. ' recordfilter(record)] );
    else
        logmsg(['Cannot read image information and can thus not compute analyse neurites. ' recordfilter(record)] );
    end
else
    record = tp_analyse_neurites( record,params );
end

if is_movie
    record = tp_analyse_movie( record, verbose);
    record = add_distance2preferred_stimulus( record );
end

% save measures file
if exist(experimentpath(record),'dir')
    measuresfile = fullfile(experimentpath(record),'tp_measures.mat');
    measures = record.measures;
    try
        save(measuresfile,'measures','-v7');
    catch
        errormsg(['Could not write measures file ' measuresfile ]);
    end
end


% remove fields that take too much memory
record.measures = rmfields(record.measures,{'psth_tbins','psth_response','raw_t','raw_data'});



