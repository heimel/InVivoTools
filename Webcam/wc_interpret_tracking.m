function record = wc_interpret_tracking( record, verbose)
%WC_INTERPRET_TRACKING analyses tracking data
%
%  RECORD = WC_INTERPRET_TRACKING(RECORD, VERBOSE)
%
% 2019-2020, Alexander Heimel

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

if ~isfield(record.measures,'framesize')
    [~,filename] = wc_getmovieinfo(record);
    vid = VideoReader(filename);
    im = readFrame(vid);
    record.measures.framesize = size(im);
end
   
if ~isfield(record.measures,'framerate') && isfield(record.measures,'frameRate')
    record.measures.framerate = record.measures.frameRate;
end

t = record.measures.frametimes;

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
            record.measures.nose_trajectory(ind,:) = repmat(record.measures.nose(i,:),length(ind),1);
            record.measures.arse_trajectory(ind,:) = repmat(record.measures.arse(i,:),length(ind),1);
        end
    end
else
    logmsg(['Manual detection not done yet for ' recordfilter(record)]);
end

record = wc_compute_overheadstim_angles(  record, verbose);
record = wc_add_freezing_ind( record, verbose);
record = wc_add_freezing_approach( record, verbose);

logmsg(['Interpreted tracking of ' recordfilter(record)]);