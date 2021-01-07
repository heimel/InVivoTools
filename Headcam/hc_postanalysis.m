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

measures.total_intensities = measures.total_intensities/nanmean(measures.total_intensities);

record.measures = measures;

end