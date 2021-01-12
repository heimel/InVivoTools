function record = analyse_hctestrecord( record, verbose)
%ANALYSE_HCTESTRECORD analyses headcamera test record
%
% RECORD = ANALYSE_HCTESTRECORD( RECORD, VERBOSE)
%
% 2021, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

measures = record.measures;

manualstart = regexp(record.comment,'start=(\s*\d+)','tokens');
if ~isempty(manualstart)
    measures.starttime = str2double(manualstart{1});
else
    logmsg('No start given in comment');
    measures.starttime = 0;
end
logmsg(['Start = ' num2str(measures.starttime) 's']);
manualend = regexp(record.comment,'end=(\s*\d+)','tokens');
if ~isempty(manualend)
    measures.endtime = str2double(manualend{1});
else
    logmsg('No end given in comment');
    if measures.starttime==0
        measures.endtime = 30*60; % 30 minutes
    else
        measures.endtime = measures.starttime + 40;
    end
end
logmsg(['End = ' num2str(measures.endtime) 's']);




filename = fullfile(record.mouse,'Recording.mpg');
obj = VideoReader(filename);
measures.framerate = obj.FrameRate;

%
%logmsg('TEMPORARY Getting start and end from A');
%ii = record.epoch;
%load A
%A_s = A/obj.FrameRate;
%[~,filename] = fileparts( filename );
%matfilename = [filename '_numx' num2str(ii,'%02d') '_analysis.mat'];
%measures.starttime = A_s(ii,1);
%measures.endtime = A_s(ii,2);
%

obj.CurrentTime = max(0,measures.starttime );
measures.starttime = obj.CurrentTime; % might be slightly different, depending on encoding
measures.number_frames = (measures.endtime-measures.starttime)*measures.framerate + 1; % one spare

record.measures = measures;

%% Initialize or reload parameters
% if exist(matfilename,'file')
%     load(matfilename,'pupil_areas','pupil_areas_smooth',...
%         'pupil_xs','pupil_ys','pupil_rs','pupil_rs_smooth',...
%         'total_intensities',...
%         'frametimes','blinks','resets',...
%         'reference_time','im_ref','rect_crop','im_ref_crop',...
%         'im_corr',...
%         'led_center','eye_center',...
%         'pupil_thresholds','led_thresholds','par');
%     disp(['Loading previous analysis ' matfilename]);
%
%     measures.pupil_areas = pupil_areas;
%     measures.pupil_xs = pupil_xs;
%     measures.pupil_ys = pupil_ys;
%     measures.pupil_rs = pupil_rs;
%     measures.pupil_areas_smooth = pupil_areas_smooth;
%     measures.pupil_rs_smooth = pupil_rs_smooth;
%     measures.total_intensities = total_intensities;
%     measures.frametimes = frametimes;
%     measures.blinks = blinks;
%     measures.resets = resets;
%     measures.reference_time = reference_time;
%     measures.im_ref = im_ref;
%     measures.rect_crop = rect_crop;
%     measures.im_ref_crop = im_ref_crop;
%     measures.im_corr = im_corr;
%     measures.led_center = led_center;
%     measures.eye_center = eye_center;
%     measures.pupil_thresholds = pupil_thresholds;
%     measures.led_thresholds = led_thresholds;
%     measures.par = par;
%
% end

redraw = false;
if ~isfield(measures,'pupil_rs') || isempty(measures.pupil_rs) || all(isnan(measures.pupil_rs))
    redraw = true;
else
    answer = questdlg('Redraw eye information?','Redraw','Yes','No','Cancel','No');
    switch answer
        case 'Yes'
            redraw = true;
        case 'No'
            redraw = false;
        case 'Cancel'
            logmsg(['Canceled analysis of ' recordfilter(record)]);
            return
    end
end

if redraw
    measures.total_intensities = NaN(measures.number_frames,1);
    measures.led_areas = NaN(measures.number_frames,1);
    measures.led_dists = NaN(measures.number_frames,1);
    measures.pupil_areas = NaN(measures.number_frames,1);
    measures.pupil_dists = NaN(measures.number_frames,1);
    measures.pupil_xs = NaN(measures.number_frames,1);
    measures.pupil_ys = NaN(measures.number_frames,1);
    measures.pupil_rs = NaN(measures.number_frames,1);
    measures.frametimes = NaN(measures.number_frames,1);
    measures.blinks = false(measures.number_frames,1);
    measures.resets = false(measures.number_frames,1);
    
    measures.par.min_pupil_size = 40;
    measures.par.default_pupil_threshold_prctile = 10;
    measures.par.default_pupil_threshold = 100;
    measures.par.default_led_threshold = 130;
    measures.par.artefact_deviation_threshold = 15; % pxl
    
    measures.reference_time = mean([measures.starttime measures.endtime]);
    obj.CurrentTime = measures.reference_time;
    fig = figure('Name','Reference','WindowStyle','Normal');
    measures.im_ref = readFrame(obj); % first find a frame where you see the pupil and iris
    measures.im_ref = rgb2gray(measures.im_ref);
    
    happy = 0;
    while happy == 0
        imagesc(measures.im_ref);
        axis image off
        colormap gray
        hold on
        text(1,1,'Drag ROI around eye','color',[1 1 1],'VerticalAlignment','top');
        ROI_rect = drawrectangle();
        measures.rect_crop = floor(ROI_rect.Position);
        measures.im_ref_crop = measures.im_ref(measures.rect_crop(2):measures.rect_crop(2)+measures.rect_crop(4),...
            measures.rect_crop(1):measures.rect_crop(1)+measures.rect_crop(3));
        
        hold off
        imagesc(measures.im_ref_crop);
        axis image off
        colormap gray
        drawnow
        z = questdlg('Are you happy with the ROI?', ...
            'Happy', ...
            'Yes','No','Cancel','No');
        switch z
            case 'Yes'
                happy = 1;
            case 'No'
                happy = 0;
            case 'Cancel'
                close(fig)
                logmsg(['Canceled analysis of ' recordfilter(record)]);
                return
        end
    end
    
    happy = false;
    while ~happy
        
        
        % Get led reflection center
        imagesc(measures.im_ref_crop);
        axis image off
        colormap gray
        
        hold on
        ht = text(1,1,'click on led reflection center','color',[1 1 1],'VerticalAlignment','top');
        drawnow
        h1 = drawpoint();
        measures.led_center = h1.Position;
        delete(ht);
        
        % Get eye center
        ht = text(1,1,'click on eye center','color',[1 1 1],'VerticalAlignment','top');
        h1 = drawpoint();
        measures.eye_center = h1.Position;
        delete(ht);
        
        z = questdlg('Are you happy with the positions?', ...
            'Happy', ...
            'Yes','No','Cancel','No');
        switch z
            case 'Yes'
                happy = true;
            case 'No'
                happy = false;
            case 'Cancel'
                close(fig)
                logmsg(['Canceled analysis of ' recordfilter(record)]);
                return
        end
        
        
    end
    
    
    
    happy = 0;
    while happy == 0
        
        % Get iris region
        hold off
        imagesc(measures.im_ref_crop);
        axis image off
        colormap gray
        
        hold on
        text(1,1,'Select iris region. Stay away from sides, but you can include pupil and led.','color',[1 1 1],'VerticalAlignment','top');
        roi = drawpolygon('Color','r');
        xi = roi.Position(:,1);
        yi = roi.Position(:,2);
        xi(end+1) = xi(1); %#ok<AGROW>
        yi(end+1) = yi(1); %#ok<AGROW>
        bw_iris = uint8(poly2mask(xi,yi,size(measures.im_ref_crop,1),size(measures.im_ref_crop,2)));
        
        % Remove pupil from correction image
        hold off
        imagesc(measures.im_ref_crop);
        axis image off
        colormap gray
        
        hold on
        text(1,1,'Select region far around pupil and LED to remove','color',[1 1 1],'VerticalAlignment','top');
        roi = drawpolygon('Color','r');
        xi = roi.Position(:,1);
        yi = roi.Position(:,2);
        xi(end+1) = xi(1); %#ok<AGROW>
        yi(end+1) = yi(1); %#ok<AGROW>
        bw_pupil_led = uint8(poly2mask(xi,yi,size(measures.im_ref_crop,1),size(measures.im_ref_crop,2)));
        
        
        ind = logical(bw_iris.* (1-bw_pupil_led));
        measures.par.default_pupil_threshold = prctile(measures.im_ref_crop(ind),...
            measures.par.default_pupil_threshold_prctile);
        disp(['Pupil threshold = ' num2str(measures.par.default_pupil_threshold)]);
        
        measures.im_corr = medfilt2(measures.par.default_pupil_threshold + 2 - measures.im_ref_crop ); % added 2
        measures.im_corr = measures.im_corr .* (1-bw_pupil_led);
        hold off
        imagesc(measures.im_corr);
        z = questdlg('Are you happy with the correction image?', ...
            'HAPPY', ...
            'Yes','No','No');
        switch z
            case 'Yes'
                happy = 1;
            case 'No'
                happy = 0;
            case 'Cancel'
                happy = 0;
        end
        
    end
    measures.pupil_thresholds = NaN(measures.number_frames,1);
    measures.pupil_thresholds(1) = measures.par.default_pupil_threshold ;
    measures.led_thresholds = NaN(measures.number_frames,1);
    measures.led_thresholds(1) = measures.par.default_led_threshold;
    close(fig);
end % no previous analysis
record.measures = measures;

record = hc_trackpupil(record,obj,verbose);
%record.measures.par.artefact_deviation_threshold = record.measures.par.artefact_deviation_threshold*1.2;
record = hc_postanalysis(record,verbose);


