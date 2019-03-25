function record = wc_interpret_tracking( record, verbose)
%WC_INTERPRET_TRACKING analyses tracking data
%
%  RECORD = WC_INTERPRET_TRACKING(RECORD, VERBOSE)
%
% 2019, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

if ~isfield(record.measures,'frametimes')
   logmsg(['First doing wc_track_mouse of ' recordfilter(record)]);
   record = wc_track_mouse(record,[],verbose);
end

if ~isfield(record.measures,'frametimes') || ~isfield(record.measures,'stim_trajectory')
    return
end

if ~isfield(record.measures,'stim_trajectory')
    logmsg(['No stim_trajectory field in ' recordfilter(record)]);
    return
end
    
t = record.measures.frametimes;
nose_pxl = record.measures.nose_trajectory;
arse_pxl = record.measures.arse_trajectory;
stim_pxl = record.measures.stim_trajectory;

% correct with manual detection
if isfield(record.measures,'stim') && ~isempty(record.measures.stim)
    indman = find(~isnan(record.measures.stim(:,1)));
    if ~isempty(indman)
        for i=indman(:)'
            ind = find(t>=record.measures.freezetimes(i,1) & t<=record.measures.freezetimes(i,2));
            
            if verbose
                wc_show_frame(record,[],t(ind(1)),[],0.3)
                hold on
                plot(record.measures.nose(i,1),record.measures.nose(i,2),'go')
                plot(record.measures.arse(i,1),record.measures.arse(i,2),'ro')
            end
            nose_pxl(ind,:) = repmat(record.measures.nose(i,:),length(ind),1);
            arse_pxl(ind,:) = repmat(record.measures.arse(i,:),length(ind),1);
        end
    end
else
    logmsg(['Manual detection not done yet for ' recordfilter(record)]);
end

nose_pxl = movmedian(nose_pxl,5,'omitnan');
arse_pxl = movmedian(arse_pxl,5,'omitnan');
%stim_pxl = movmedian(stim_pxl,3);

[azimuth,elevation,~] = wc_compute_overheadstim_angles( nose_pxl,arse_pxl,stim_pxl);

record.measures.azimuth_trajectory = azimuth;
record.measures.elevation_trajectory = elevation;

if verbose
    wc_plot_polar_trajectory(record);
end

logmsg(['Interpreted tracking of ' recordfilter(record)]);