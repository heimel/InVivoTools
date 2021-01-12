function record = hc_trackpupil( record, obj, verbose)
%HC_TRACKPUPIL tracks pupil in headcamera test record
%
% RECORD = HC_TRACKPUPIL( RECORD, VERBOSE)
%
% 2021, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true; %#ok<NASGU>
end
if nargin<2 || isempty(obj)
    filename = fullfile(record.mouse,'Recording.mpg');
    obj = VideoReader(filename);
    framerate = obj.FrameRate;

end

measures = record.measures;

pupil_areas = measures.pupil_areas;
pupil_xs = measures.pupil_xs;
pupil_ys = measures.pupil_ys;
pupil_rs = measures.pupil_rs;
frametimes = measures.frametimes;
blinks = measures.blinks;
resets = measures.resets;
reference_time = measures.reference_time;
im_ref = measures.im_ref;
rect_crop = measures.rect_crop;
im_ref_crop = measures.im_ref_crop;
im_corr = measures.im_corr;
led_center = measures.led_center;
eye_center = measures.eye_center;
pupil_thresholds = measures.pupil_thresholds;
led_thresholds = measures.led_thresholds;
par = measures.par;




analyse = all(isnan(pupil_areas));

% to override:
% analyse = true;
if analyse
    disp(['Analysing from ' num2str(measures.starttime) 's to ' num2str(measures.endtime) 's']);
else
    disp(['Playing from ' num2str(measures.starttime) 's to ' num2str(measures.endtime) 's']);
end

fig = figure('WindowKeyPressFcn',@capture_keypress,'UserData','','WindowStyle','modal');
currAxes = axes;
%h = [];
stop_playing = false;
skip_frames = 0;
play = false;
show_processed = true;
show_circle = true;
show_zoom = true;
show_label = true;
stepping = true;
manual_tune = true;

% for growing led reflection area
se_led = strel('sphere',1);

msg = 'Paused analysis. +/- to change pupil threshold. [/] to change led threshold. b for blink. p to continue.';

disp('Keys: ')
disp(' q: quit');
disp(' p: pause or proceed');
disp(' >: step one frame forward');
disp(' <: step one frame backward');
disp(' a: toggle analysis');
disp(' t: toggle patches');
disp(' c: toggle show pupil circle');
disp(' z: toggle zoom');
disp(' g: goto time');
disp(' b: mouse blinks');
disp(' l: toggle label');
disp(' +: increase pupil threshold (increase pupil area)');
disp(' -: decrease pupil threshold (decrease pupil area)');
disp(' ]: increase led threshold (decrease led area)');
disp(' [: decrease led threshold (increase led area)');

frame = 0;
tic;
obj.CurrentTime = measures.starttime;

frametimes(frame+1) = obj.CurrentTime;
while hasFrame(obj) && ~stop_playing && obj.CurrentTime<measures.endtime
    lasttoc = toc;
    show_processed = show_processed && analyse;
    
    if play || stepping
        noframesleft = false;
        for f = 1:skip_frames
            readFrame(obj); % first find a frame where you see the pupil
            frame = frame + 1;
            frametimes(frame+1) = obj.CurrentTime;
            if ~hasFrame(obj)
                noframesleft = true;
                break
            end
        end
        if noframesleft
            break
        end
        
        
        if frame<=length(frametimes) && ~isnan(frametimes(frame+1)) &&  frametimes(frame+1) ~= obj.CurrentTime
            logmsg([num2str(frametimes(frame)) ': Glitch']);
            obj.CurrentTime = frametimes(frame);
            im = readFrame(obj);
            if frametimes(frame+1) ~= obj.CurrentTime
                close(fig);
                errormsg('Frametime changed unexpectedly.');
                return
            end
        end
        
        im = readFrame(obj); % first find a frame where you see the pupil
        frame = frame + 1;

        if frame<length(frametimes) && ~isnan(frametimes(frame+1)) &&  frametimes(frame+1) ~= obj.CurrentTime
            logmsg([num2str(frametimes(frame)) ': Glitch']);
            obj.CurrentTime = frametimes(frame);
            im = readFrame(obj);
            if frametimes(frame+1) ~= obj.CurrentTime
                close(fig);
                errormsg('Frametime changed unexpectedly.');
                return
            end
        end
        frametimes(frame+1) = obj.CurrentTime;
        im = rgb2gray(im);
        
        % crop
        im_crop = im(rect_crop(2):rect_crop(2)+rect_crop(4),rect_crop(1):rect_crop(1)+rect_crop(3),:);
        
        % median filter
        im_crop = medfilt2(im_crop);
        
        stepping = false;
    end

    if ~isnan(led_thresholds(frame))
        led_threshold = led_thresholds(frame) ;
    end
    if ~isnan(pupil_thresholds(frame))
        pupil_threshold = pupil_thresholds(frame);
    end
    
    im_proc = double(im_crop);
    
    if analyse
        total_intensities(frame) = sum(im_crop(:));
        
        % find led reflection
        im_proc = im_proc>led_threshold ;
        im_proc = imdilate(im_proc,se_led); % enlarge around reflection
        comps = bwconncomp(im_proc);
        props = regionprops(comps);
        mindist = Inf;
        led_component = [];
        for i = 1:length(props)
            dist = norm(props(i).Centroid - led_center);
            if dist<mindist && props(i).Area < 2000
                mindist = dist;
                led_component = i;
            end
        end
        
        im_without_led = im_crop;
        
        % add correction mask
        im_without_led = im_without_led + im_corr;
        if isempty(led_component)
%             if play
%                 disp(['No led components found at ' num2str(obj.CurrentTime)]);
%             end
            led_found = false;
        elseif props(led_component).Area>150
%             if play
%                 disp(['Central led component is too large at ' num2str(obj.CurrentTime)]);
%             end
            led_found = false;
        elseif props(led_component).Area<50
%             if play
%                 disp(['Central led component is too small at ' num2str(obj.CurrentTime)]);
%             end
            led_found = false;
        else
            intensities = im_without_led(comps.PixelIdxList{led_component});
            min_intensity = prctile(intensities(intensities<led_threshold),15);
            im_without_led(comps.PixelIdxList{led_component}) = min_intensity;
            %led_areas(frame) = props(led_component).Area;
            %led_dists(frame) = norm(props(led_component).Centroid - led_center);
            led_found = true;
        end
        
%         if play && ~led_found && manual_tune
%             play = false;
%             disp(msg);
%         end
        
        % find pupil component
        im_proc = im_without_led<pupil_threshold ;
        im_proc = bwmorph(im_proc,'open');
        im_proc = bwmorph(im_proc,'close');
        im_proc = bwmorph(im_proc,'open');
        im_proc = imfill(im_proc,8,'holes');
        pupil_comps = bwconncomp(im_proc);
        pupil_props = regionprops(pupil_comps);
        mindist = Inf;
        pupil_component = [];
        for i = 1:length(pupil_props)
            dist = norm(pupil_props(i).Centroid - eye_center);
            if dist<mindist && pupil_props(i).Area > par.min_pupil_size
                mindist = dist;
                pupil_component = i;
            end
        end
        
        if isempty(pupil_component)
            if play
                disp(['No pupil components found at ' num2str(obj.CurrentTime)]);
            end
            pupil_found = false;
        elseif pupil_props(pupil_component).Area>2700
            if play
                disp(['Central pupil component is too large ' num2str(pupil_props(pupil_component).Area) ' at ' num2str(obj.CurrentTime)]);
            end
            pupil_found = false;
        else
            pupil_areas(frame) = pupil_props(pupil_component).Area;
            % pupil_dists(frame) = norm(pupil_props(pupil_component).Centroid - eye_center);
            pupil_found = true;
        end
        
        if play && ~pupil_found && manual_tune && ~blinks(frame) && ~resets(frame)
            play = false;
            disp(msg);
        end
        
        
        if pupil_found
            % fit circle
            [row,col] = ind2sub([size(im_proc,1),size(im_proc,2)],pupil_comps.PixelIdxList{pupil_component});
            k = convhull([row,col]);
            [pupil_xs(frame),pupil_ys(frame),pupil_rs(frame)] = circle_fit(row(k),col(k));
            
            if frame>1
                pupil_xs_dev = pupil_xs(frame) - pupil_xs(frame-1);
                pupil_ys_dev = pupil_ys(frame) - pupil_ys(frame-1);
                pupil_deviation =  sqrt(pupil_xs_dev.^2 + pupil_ys_dev.^2);
                if pupil_deviation > 0.75 * par.artefact_deviation_threshold
                    if play
                        disp(['Large jump in pupil position at ' num2str(obj.CurrentTime)]);
                        disp(msg)
                    end
                    play = false;
                end
            end
        end
    end % analyse
    
    colormap gray
    if show_processed
        im_composite = repmat(im_without_led,1,1,3);
        im_ind = ones(size(im_composite),'uint8');
        im_ind(:,:,1) = 1-im_proc;
        if ~isempty(pupil_component)
            im_proc( pupil_comps.PixelIdxList{pupil_component}) = 0;
            im_ind(:,:,2) = 1-im_proc;
        end
        im_composite = im_composite.*im_ind;
    end
    if show_zoom && show_processed
        image(im_composite,'Parent',currAxes)
    elseif show_zoom && ~show_processed
        image(im_crop,'Parent',currAxes)
    elseif ~show_zoom && show_processed
        imx = repmat(im,1,1,3);
        imx(rect_crop(2) + (1:size(im_composite,1)),rect_crop(1) + (1:size(im_composite,2)),:) = im_composite;
        image(imx,'Parent',currAxes)
    else
        image(im,'Parent',currAxes)
    end
    disableDefaultInteractivity(currAxes);
    currAxes.Visible = 'off';
    if show_circle
        hold on
        if show_zoom
            circle(pupil_ys(frame),pupil_xs(frame),pupil_rs(frame));
        else
            circle(pupil_ys(frame)+rect_crop(1),pupil_xs(frame)+rect_crop(2),pupil_rs(frame));
        end
        hold off
    end
    
    xl = xlim;
    if blinks(frame)
        text(xl(2)-5,1,'Blink','VerticalAlignment','top','HorizontalAlignment','right','color',[ 1 1 1]);
    end
    if resets(frame)
        text(xl(2)-5,1,'Reset','VerticalAlignment','top','HorizontalAlignment','right','color',[ 1 1 1]);
    end
    
    if show_label
        text(5,2,[num2str(obj.CurrentTime)...
            ', Pupil > ' num2str(pupil_threshold) ...
            ', LED > ' num2str(led_threshold) ...
            ', Analyse = ' num2str(analyse)],...
            'color',[1 1 1],'verticalalignment','top')
    end
    if ~isempty(fig.UserData)
        switch fig.UserData
            case 'q' % quit
                stop_playing = true;
            case 'z' % zoom
                show_zoom = ~show_zoom;
            case 'c' % circle around pupil
                show_circle = ~show_circle;
            case 'f'
                skip_frames = skip_frames + 1;
                logmsg(['Skipping ' num2str(skip_frames) ' frames. s to slow down.']);
            case 's'
                skip_frames = max(0,skip_frames - 1);
                logmsg(['Skipping ' num2str(skip_frames) ' frames. f to speed up.']);
            case 'p' % play / proceed
                play = ~play;
            case 't' % toggle show patches
                show_processed = ~show_processed;
            case 'a' % toggle analysis
                analyse = ~analyse;
            case {'>','.'} % step one frame forward
                stepping = true;
            case {'<',','} % step one frame back
                disp(['Before step: frame = ' num2str(frame) ...
                    'frametimes(frame) = ' num2str(frametimes(frame)) ...
                    ', CurrentTime = ' num2str(obj.CurrentTime)]);

                
                stepping = true;
                frame = max(1,frame-2);
                obj.CurrentTime = frametimes(frame);
                pause(0.1); % setting CurrentTime takes time?
                readFrame(obj);
                pupil_threshold = pupil_thresholds(frame);
                led_threshold = led_thresholds(frame);
                
                disp(['After step: frame = ' num2str(frame) ...
                    'frametimes(frame) = ' num2str(frametimes(frame)) ...
                    ', CurrentTime = ' num2str(obj.CurrentTime)]);
        
            case 'g' % goto time
                answer = inputdlg('Goto time: ','Go to time',1,{num2str(obj.CurrentTime)});
                goto_time = str2double(answer) - 1/measures.framerate;
                frame = find(frametimes>goto_time,1);
                obj.CurrentTime = frametimes(frame);
                readFrame(obj);
                stepping = true;
                pupil_threshold = pupil_thresholds(frame);
                led_threshold = led_thresholds(frame);
            case 'l'
                show_label = ~show_label;
        end
        if analyse
            switch fig.UserData 
                case {'+','='} % increase pupil threshold (increase pupil area)
                    pupil_threshold = min(255,pupil_threshold + 1);
                case '-' % decrease pupil threshold (decrease pupil area)
                    pupil_threshold = max(0,pupil_threshold - 1);
                case '[' % increase led threshold (decrease led area)
                    led_threshold = min(255,led_threshold + 5);
                case ']' % decrease led threshold (increase led area)
                    led_threshold = max(0,led_threshold - 5);
                case 'b' % blink
                    blinks(frame) = true;
                    play = true;
                case 'r' % reset
                    resets(frame) = true;
                    play = true;
            end
        end % analysis key pressed
        fig.UserData = [];
    end % key pressed

    
    pupil_thresholds(frame) = pupil_threshold;
    led_thresholds(frame) = led_threshold;
    drawnow;
    newtoc = toc;
    waittime = 1/measures.framerate - (newtoc-lasttoc);
    pause(waittime);
end
if length(frametimes)==length(pupil_xs)+1
    frametimes(end) = []; % remove extra frametime
end
close(fig);
logmsg([ num2str(obj.CurrentTime) ': Stopped playing'])



measures.pupil_areas = pupil_areas;
measures.pupil_xs = pupil_xs;
measures.pupil_ys = pupil_ys;
measures.pupil_rs = pupil_rs;
measures.frametimes = frametimes;
measures.blinks = blinks;
measures.resets = resets;
measures.reference_time = reference_time;
measures.im_ref = im_ref;
measures.rect_crop = rect_crop;
measures.im_ref_crop = im_ref_crop;
measures.im_corr = im_corr;
measures.led_center = led_center;
measures.eye_center = eye_center;
measures.pupil_thresholds = pupil_thresholds;
measures.led_thresholds = led_thresholds;
measures.par = par;

record.measures = measures;
end

%%
function [xo,yo,R] = circle_fit(x,y) 
% A function to find the best circle fit (radius and center location) to
% given x,y pairs
%
% Val Schmidt
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% 2012
%
% Arguments:
% x:         x coordinates
% y:         y coordinates
%
% Output:
% xo:        circle x coordinate center
% yo:        circle y coordinate center
% R:         circle radius
x = x(:);
y = y(:);
% Fitting a circle to the data - least squares style.
%Here we start with
% (x-xo).^2 + (y-yo).^2 = R.^2
% Rewrite:
% x.^2 -2 x xo + xo^2 + y.^2 -2 y yo + yo.^2 = R.^2
% Put in matrix form:
% [-2x -2y 1 ] [xo yo -R^2+xo^2+yo^2]' = -(x.^2 + y.^2)
% Solve in least squares way...
A = [-2*x -2*y ones(length(x),1)];
x = A\-(x.^2+y.^2);
xo=x(1);
yo=x(2);
R = sqrt(  xo.^2 + yo.^2  - x(3));
end

function capture_keypress(handle,event)
handle.UserData = lower(event.Character);
end

function circle(x,y,r)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang = 0:0.01:2*pi;
xp = r*cos(ang);
yp = r*sin(ang);
plot(x+xp,y+yp,'y--','LineWidth',1);
end