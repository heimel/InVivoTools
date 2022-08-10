function record = hc_postanalysis( record, verbose)
%HC_POSTANALYSIS postanalysis of head camera record
%
% RECORD = HC_POSTANALYSIS( RECORD, VERBOSE )
% 
% 2021-2022, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true; %#ok<NASGU>
end

measures = record.measures;
if isempty(measures) || ~isfield(measures,'pupil_xs')
    return
end

% Remove blinks
ind = find(measures.blinks);

% Remove around blinks for smoothing
if ~isfield(measures.par,'blink_blanking_time')
    measures.par.blink_blanking_time = 0.4; %s
end
ext = measures.par.blink_blanking_time * measures.framerate;
ext = -ext:ext;

ind_extended = repmat(ind,1,length(ext)) + repmat(ext,length(ind),1);
ind_blinks = unique(ind_extended);
ind_no_blinks = setdiff(1:length(measures.frametimes),ind_blinks);

% remove artefacts
measures.pupil_xs_dev = measures.pupil_xs - median(measures.pupil_xs(ind_no_blinks),'omitnan');
measures.pupil_ys_dev = measures.pupil_ys - median(measures.pupil_ys(ind_no_blinks),'omitnan');
measures.pupil_deviations =  sqrt(measures.pupil_xs_dev.^2 + measures.pupil_ys_dev.^2);

ind_artefacts = find(measures.pupil_deviations > measures.par.artefact_deviation_threshold);

ind_artefacts = unique( [ind_artefacts; ind_blinks]);

measures.pupil_deviations_smooth = measures.pupil_deviations;
measures.pupil_deviations_smooth(ind_artefacts) = NaN;
measures.pupil_deviations_smooth = movmedian(measures.pupil_deviations_smooth,ceil(1.0*measures.framerate),'omitnan');

measures.pupil_areas_smooth = measures.pupil_areas;
measures.pupil_areas_smooth(ind_artefacts) = NaN;
measures.pupil_areas_smooth = movmedian(measures.pupil_areas_smooth,ceil(1.0*measures.framerate),'omitnan');

measures.pupil_rs_smooth = measures.pupil_rs;
measures.pupil_rs_smooth(ind_artefacts) = NaN;
measures.pupil_rs_smooth = movmedian(measures.pupil_rs_smooth,ceil(1.0*measures.framerate),'omitnan');

measures.pupil_noise = sqrt(mean( (measures.pupil_areas - measures.pupil_areas_smooth).^2 ,'omitnan')); 
measures.total_intensities = measures.total_intensities/mean(measures.total_intensities,'omitnan');

manualtouching = regexp(record.comment,'touching=(\s*\d+)','tokens');
if ~isempty(manualtouching)
    measures.touching = str2double(manualtouching{1});
else
    measures.touching = [];
end

record.measures = measures;

end