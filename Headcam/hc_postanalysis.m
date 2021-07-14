function record = hc_postanalysis( record, verbose)
%HC_POSTANALYSIS postanalysis of head camera record
%
% RECORD = HC_POSTANALYSIS( RECORD, VERBOSE )
% 
% 2021, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true; %#ok<NASGU>
end

measures = record.measures;
if isempty(measures) || ~isfield(measures,'pupil_xs')
    return
end



% remove blinks
    ind = find(measures.blinks);
    measures.pupil_areas(ind) = NaN;

% remove artefacts
measures.pupil_xs_dev = measures.pupil_xs - nanmedian(measures.pupil_xs);
measures.pupil_ys_dev = measures.pupil_ys - nanmedian(measures.pupil_ys);
measures.pupil_deviations =  sqrt(measures.pupil_xs_dev.^2 + measures.pupil_ys_dev.^2);
ind_artefacts = measures.pupil_deviations > measures.par.artefact_deviation_threshold;



measures.pupil_areas_smooth = measures.pupil_areas;
measures.pupil_areas_smooth(ind_artefacts) = NaN;
measures.pupil_areas_smooth = movmedian(measures.pupil_areas_smooth,ceil(1.0*measures.framerate),'omitnan');

measures.pupil_rs_smooth = measures.pupil_rs;
measures.pupil_rs_smooth(ind_artefacts) = NaN;
measures.pupil_rs_smooth = movmedian(measures.pupil_rs_smooth,ceil(1.0*measures.framerate),'omitnan');

measures.pupil_noise = sqrt(nanmean( (measures.pupil_areas - measures.pupil_areas_smooth).^2 )); 

measures.total_intensities = measures.total_intensities/nanmean(measures.total_intensities);

manualtouching = regexp(record.comment,'touching=(\s*\d+)','tokens');
if ~isempty(manualtouching)
    measures.touching = str2double(manualtouching{1});
else
    measures.touching = [];
end


record.measures = measures;

end