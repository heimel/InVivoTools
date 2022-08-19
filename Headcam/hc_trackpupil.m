function record = hc_trackpupil( record, obj, verbose)
%HC_TRACKPUPIL tracks pupil in headcamera test record
%
% RECORD = HC_TRACKPUPIL( RECORD, VERBOSE)
%
% 2021-2022, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true; %#ok<NASGU>
end
if nargin<2 || isempty(obj)
    filename = hc_filename(record);
    if ~exist(filename,'file')
        logmsg(['Cannot find movie ' filename '. Make sure it is in the current folder.']);
        return
    end
    obj = VideoReader(filename);
end

params = hcprocessparams( record );

measures = record.measures;
if isempty(measures)
    measures.starttime = [];
    measures.endtime = [];
    measures.framerate = [];
    measures.number_frames = [];
    measures.total_intensities = [];
    measures.glint_areas = [];
    measures.glint_dists = [];
    measures.pupil_areas = [];
    measures.pupil_dists = [];
    measures.pupil_xs = [];
    measures.pupil_ys = [];
    measures.pupil_rs = [];
    measures.frametimes = [];
    measures.blinks = [];
    measures.resets = [];
    measures.par = [];
    measures.reference_time = [];
    measures.im_ref = [];
    measures.rect_crop = [];
    measures.im_ref_crop = [];
    measures.glint_center = [];
    measures.eye_center = [];
    measures.im_corr = [];
    measures.pupil_thresholds = [];
    measures.glint_thresholds = [];
    measures.pupil_xs_dev = [];
    measures.pupil_ys_dev = [];
    measures.pupil_deviations = [];
    measures.pupil_areas_smooth = [];
    measures.pupil_rs_smooth = [];
    measures.pupil_noise = [];
    measures.touching = [];
    measures.ref_similarity = [];
end


pupil_areas = measures.pupil_areas;
pupil_xs = measures.pupil_xs;
pupil_ys = measures.pupil_ys;
pupil_rs = measures.pupil_rs;
frametimes = measures.frametimes;
framerate = measures.framerate;
blinks = measures.blinks;
resets = measures.resets;
reference_time = measures.reference_time;
im_ref = measures.im_ref;
rect_crop = measures.rect_crop;
im_ref_crop = measures.im_ref_crop;
im_corr = measures.im_corr;
glint_center = measures.glint_center;
eye_center = measures.eye_center;
pupil_thresholds = measures.pupil_thresholds;
glint_thresholds = measures.glint_thresholds;
par = measures.par;
ref_similarity = measures.ref_similarity;
total_intensities = measures.total_intensities;


if isempty(framerate)
    framerate = obj.FrameRate;
end

analyse = all(isnan(pupil_areas));

% to override:
% analyse = true;
if analyse
    disp(['Analysing from ' num2str(measures.starttime) 's to ' num2str(measures.endtime) 's']);
else
    disp(['Playing from ' num2str(measures.starttime) 's to ' num2str(measures.endtime) 's']);
end

%% Set up figure
fig = figure('Name','Pupil tracker','NumberTitle','off',...
    'WindowKeyPressFcn',@capture_keypress,'UserData','','WindowStyle','modal');
currAxes = axes('Position',[0.05 0.2 0.5 0.8]);
help_panel = uipanel(fig,'Position',[0.7 0.1 0.25 0.8]);

plot_radius(frametimes,pupil_rs,1,fig);
display_message('Adjust pupil and glint threshold. Press space to start',fig);

key_bindings = params.key_bindings;
show_key_bindings(key_bindings,help_panel);

y = 20; %pt
uicontrol(fig,'Style','Text','Units','points','Position',[10 y 50 10],'String','Pupil <');
edit_pupil_threshold = uicontrol(fig,'Style','Edit','Units','points','Position',[60 y 30 10],'String','   ');
uicontrol(fig,'Style','Text','Units','points','Position',[90 y 50 10],'String','glint >');
edit_glint_threshold = uicontrol(fig,'Style','Edit','Units','points','Position',[160 y 30 10],'String','   ');

axis image

%% Initialize main loop
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
real_time_display = true;
view = true;

dbs = dbstack;
if length(dbs)>1 && strcmp(dbs(2).name ,'play_hctestrecord')
    manual_tune = false;
end

% for growing glint reflection area
se_glint = strel('sphere',1);

%% Main loop
axes(currAxes);

frame = 0;
tic;
if ~isempty(measures.starttime)
    obj.CurrentTime = measures.starttime;
end

frametimes(frame+1) = obj.CurrentTime;
if ~isempty(measures.endtime)
    endtime = measures.endtime;
else
    endtime = inf;
end

glint_found = true;



while hasFrame(obj) && ~stop_playing && obj.CurrentTime<endtime
    lasttoc = toc;
    show_processed = show_processed && analyse;
    
    %% Read and process image
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
            readFrame(obj);
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
        if ~isempty(rect_crop)
            im_crop = im(rect_crop(2):rect_crop(2)+rect_crop(4),rect_crop(1):rect_crop(1)+rect_crop(3),:);
        else
            im_crop = im;
        end
        
        % median filter
        im_crop = medfilt2(im_crop);
        
        stepping = false;
    end
    
    if length(glint_thresholds)>=frame && ~isnan(glint_thresholds(frame))
        glint_threshold = glint_thresholds(frame) ;
    elseif frame>1 && length(glint_thresholds)>frame-1 && ~isnan(glint_thresholds(frame-1))
        glint_threshold = glint_thresholds(frame-1);
    elseif isempty(glint_threshold)
        glint_threshold = par.default_glint_threshold;
    end
    if length(pupil_thresholds)>=frame && ~isnan(pupil_thresholds(frame))
        pupil_threshold = pupil_thresholds(frame);
    elseif frame>1 && length(pupil_thresholds)>frame-1 && ~isnan(pupil_thresholds(frame-1))
        pupil_threshold = pupil_thresholds(frame-1);
    elseif isempty(pupil_threshold)
        pupil_threshold = par.default_pupil_threshold;
    end
    im_proc = double(im_crop);
    
    %% Analyse
    if analyse
        total_intensities(frame) = sum(im_crop(:));
        
        % find glint reflection
        im_proc = im_proc>glint_threshold ;
        im_proc = imdilate(im_proc,se_glint); % enlarge around reflection
        comps = bwconncomp(im_proc);
        props = regionprops(comps);
        mindist = Inf;
        glint_component = [];
        for i = 1:length(props)
            dist = norm(props(i).Centroid - glint_center);
            if dist<mindist && props(i).Area < 2000
                mindist = dist;
                glint_component = i;
            end
        end
        
        im_without_glint = im_crop;
        
        % add correction mask
        if ~isempty(im_corr)
            im_without_glint = im_without_glint + im_corr;
        end
        if isempty(glint_component)
            if glint_found
                display_message('No potential glint components detected');
            end
            glint_found = false;
        elseif props(glint_component).Area>params.glint_area_max
            if glint_found
                display_message(['Potential glint too large (' num2str(props(glint_component).Area) ' pxl^2). Consider increasing glint_area_max in processparams_local.']);
            end
            glint_found = false;
        elseif props(glint_component).Area<params.glint_area_min
            if glint_found
                display_message(['Potential glint too small (' num2str(props(glint_component).Area) ' pxl^2). Consider decreasing glint_area_min in processparams_local.']);
            end
            glint_found = false;
        else
            intensities = im_without_glint(comps.PixelIdxList{glint_component});
            glint_intensity_min = prctile(intensities(intensities<glint_threshold),15);
            im_without_glint(comps.PixelIdxList{glint_component}) = glint_intensity_min;
            glint_found = true;
        end
        
        % find pupil component
        im_proc = im_without_glint<pupil_threshold ;
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
            if dist<mindist && pupil_props(i).Area > par.pupil_area_min
                mindist = dist;
                pupil_component = i;
            end
        end
        
        if isempty(pupil_component)
            if play && ~isempty(pupil_xs)
                display_message(['No pupil components found at ' num2str(obj.CurrentTime)]);
            end
            pupil_found = false;
        elseif pupil_props(pupil_component).Area>params.pupil_area_max
            if play
                display_message(['Central pupil component is too large ' num2str(pupil_props(pupil_component).Area) ' at ' num2str(obj.CurrentTime)]);
            end
            pupil_found = false;
        else
            pupil_areas(frame) = pupil_props(pupil_component).Area;
            pupil_found = true;
        end
        
        ref_similarity(frame) = corr2(im_crop,im_ref_crop); % to check blinking
        if ~pupil_found && ref_similarity(frame)<par.automatic_blinking_threshold
            blinks(frame) = true;
        end
        
        if play && ~pupil_found && manual_tune
            display_message(['Similarity to reference [0-1]: ' num2str(ref_similarity(frame),2)]);
            if length(blinks)>=frame && blinks(frame)
                continue
            end
            if length(resets)>=frame && resets(frame)
                continue
            end
            play = false;
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
                if pupil_deviation > params.artefact_warning * par.artefact_deviation_threshold && ~blinks(frame)
                    if play
                        display_message(['Large jump in pupil position at ' num2str(obj.CurrentTime) '. Consider changing artefact_warning or artefact_deviation_threshold.']);
                    end
                    play = false;
                end
            end
        end
    end % analyse
    
    %% Show image
    if view
        colormap gray
        if show_processed
            im_composite = repmat(im_without_glint,1,1,3);
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
            axis image
        elseif show_zoom && ~show_processed
            image(im_crop,'Parent',currAxes)
            axis image
        elseif ~show_zoom && show_processed
            imx = repmat(im,1,1,3);
            imx(rect_crop(2) + (1:size(im_composite,1)),rect_crop(1) + (1:size(im_composite,2)),:) = im_composite;
            image(imx,'Parent',currAxes)
            axis image
        else
            image(im,'Parent',currAxes)
            axis image
        end
        
        disableDefaultInteractivity(currAxes);
        currAxes.Visible = 'off';
        if show_circle && ~isempty(pupil_ys)
            hold on
            if show_zoom
                circle(pupil_ys(frame),pupil_xs(frame),pupil_rs(frame));
            else
                circle(pupil_ys(frame)+rect_crop(1),pupil_xs(frame)+rect_crop(2),pupil_rs(frame));
            end
            hold off
        end
        
        xl = xlim;
        if ~isempty(blinks) && blinks(frame)
            text(xl(2)-5,1,'Blink','VerticalAlignment','top','HorizontalAlignment','right','color',[ 1 1 1]);
        end
        if ~isempty(resets) && resets(frame)
            text(xl(2)-5,1,'Reset','VerticalAlignment','top','HorizontalAlignment','right','color',[ 1 1 1]);
        end
        
        if show_label
            text(5,2,[num2str(obj.CurrentTime,'%0.02f')...
                ', Analyse = ' num2str(analyse)],...
                'color',[1 1 1],'verticalalignment','top')
        end
        drawnow;
    end % view
    edit_pupil_threshold.String = num2str(pupil_threshold);
    edit_glint_threshold.String = num2str(glint_threshold);
    
    %% Perform user actions
    if ~isempty(fig.UserData)
        ind = find(contains(key_bindings(:,2),fig.UserData));
        if ~isempty(ind)
            action = key_bindings{ind,1};
        else
            action = '';
        end
        
        switch action
            case 'quit'
                stop_playing = true;
            case 'zoom'
                show_zoom = ~show_zoom;
            case 'pupil'
                show_circle = ~show_circle;
            case 'skipmore'
                skip_frames = skip_frames + 1;
                display_message(['Skipping ' num2str(skip_frames) ' frames. s to slow down.']);
            case 'skipless'
                skip_frames = max(0,skip_frames - 1);
                display_message(['Skipping ' num2str(skip_frames) ' frames. f to speed up.']);
            case 'realtime'
                real_time_display = ~real_time_display;
                display_message(['Real time display set to ' char(string(real_time_display))]);
            case 'pause'
                play = ~play;
            case 'patches' % toggle show patches
                show_processed = ~show_processed;
            case 'analyse' % toggle analysis
                analyse = ~analyse;
                manual_tune = analyse;
            case 'forward' % step one frame forward
                stepping = true;
            case 'backward' % step one frame back
                stepping = true;
                frame = max(1,frame-2);
                obj.CurrentTime = frametimes(frame);
                pause(0.1); % setting CurrentTime takes time?
                readFrame(obj);
                pupil_threshold = pupil_thresholds(frame);
                glint_threshold = glint_thresholds(frame);
            case 'goto' % goto time
                answer = inputdlg('Goto time: ','Go to time',1,{num2str(obj.CurrentTime)});
                goto_time = str2double(answer) - 1/framerate;
                frame = find(frametimes>goto_time,1);
                obj.CurrentTime = frametimes(frame);
                readFrame(obj);
                stepping = true;
                pupil_threshold = pupil_thresholds(frame);
                glint_threshold = glint_thresholds(frame);
            case 'gotomissing'
                ind = find(isnan(pupil_rs(frame+1:end)) & ~blinks(frame+1:end),1);
                if isempty(ind)
                    display_message('No missing pupils following this frame.');
                else
                    frame = frame + ind - 1;
                    obj.CurrentTime = frametimes(frame);
                    readFrame(obj);
                    stepping = true;
                    pupil_threshold = pupil_thresholds(frame);
                    glint_threshold = glint_thresholds(frame);
                end
                
            case 'label'
                show_label = ~show_label;
            case 'view'
                view = ~view;
                display_message(['Viewing change to ' char(string(view))]);
        end
        if analyse
            switch action
                case 'incpupil' % increase pupil threshold (increase pupil area)
                    pupil_threshold = min(255,pupil_threshold + 1);
                case 'decpupil' % decrease pupil threshold (decrease pupil area)
                    pupil_threshold = max(0,pupil_threshold - 1);
                case 'decglint' % increase glint threshold (decrease glint area)
                    glint_threshold = min(255,glint_threshold + 5);
                case 'incglint' % decrease glint threshold (increase glint area)
                    glint_threshold = max(0,glint_threshold - 5);
                case 'blink' % blink
                    if length(blinks)<frame
                        blinks(frame) = true;
                    else % toggle
                        blinks(frame) = ~blinks(frame);
                    end
                case 'reset' % reset
                    if length(resets)<frame
                        resets(frame) = true;
                    else
                        resets(frame) = ~resets(frame);
                    end
                    play = true;
                    
                case 'clear'
                    answer = inputdlg('Clear from: ','Clear from',1,{num2str(obj.CurrentTime)});
                    clear_from = str2double(answer) ;
                    answer = inputdlg('Clear until: ','Clear until',1,{num2str(clear_from+1)});
                    clear_until = str2double(answer) ;
                    firstframe = find(frametimes>clear_from-1/framerate,1,'first');
                    lastframe = find(frametimes<clear_until+1/framerate,1,'last');
                    if ~isempty(firstframe) && ~isempty(lastframe)
                        clear_from = frametimes(firstframe);
                        clear_until = frametimes(lastframe);
                        answer = questdlg(['Clear from ' num2str(clear_from) ' to ' num2str(clear_until) '?'], ...
                            'Confirm clearing', ...
                            'Yes', 'No', 'No');
                        if strcmp(answer,'Yes')
                            pupil_xs(firstframe:lastframe) = NaN;
                            pupil_ys(firstframe:lastframe) = NaN;
                            pupil_rs(firstframe:lastframe) = NaN;
                            pupil_areas(firstframe:lastframe) = NaN;
                            pupil_thresholds(firstframe:lastframe) = NaN;
                            glint_thresholds(firstframe:lastframe) = NaN;
                            blinks(firstframe:lastframe) = false;
                            resets(firstframe:lastframe) = false;
                            plot_radius(frametimes,pupil_rs,1);
                        end
                    else
                        display_message('Error in getting framenumbers');
                    end
            end
        end % analysis key pressed
        fig.UserData = [];
    end % key pressed
    
    % Update data
    pupil_thresholds(frame) = pupil_threshold;
    glint_thresholds(frame) = glint_threshold;
    
    
    newtoc = toc;
    
    
    if real_time_display
        waittime = 1/framerate - (newtoc-lasttoc);
        pause(waittime);
    end
    
    
end % main loop

%% Wrap up
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
measures.glint_center = glint_center;
measures.eye_center = eye_center;
measures.pupil_thresholds = pupil_thresholds;
measures.glint_thresholds = glint_thresholds;
measures.par = par;
measures.ref_similarity = ref_similarity;
measures.total_intensities = total_intensities;

record.measures = measures;
end

%% Auxiliary function
function [xo,yo,R] = circle_fit(x,y)
% A function to find the best circle fit (radius and center location) to
% given x,y pairs
%
% Val Schmidt, Center for Coastal and Ocean Mapping, University of New Hampshire, 2012
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

function show_key_bindings(key_bindings,help_panel)
n_keys = size(key_bindings,1);

for i=1:n_keys
    key = key_bindings{i,2};
    switch key
        case ' '
            key = '[space]';
    end
    txt = [key ': ' key_bindings{i,3}];
    uicontrol(help_panel,'Style','text','String',txt,...
        'FontSize',8,...
        'Units','points',...
        'horizontalalignment','left',...
        'Position',[0 i*10 200 10]);
    %    disp(txt);
end
end

function plot_radius(frametimes,pupil_rs,frame,fig)
persistent ax
oldax = gca;
if nargin>3
    ax = axes(fig,'Position',[0.05 0.1 0.5 0.1] );
    hold on
end
hold(ax,'off')
plot(ax,frametimes,pupil_rs,'r.');
hold(ax,'on');
plot(ax,frametimes(frame)*[1 1],ylim(ax),'--');
set(ax,'ytick',[]);
%set(ax,'PlotBoxAspectRatioMode','manual');
%axis fill
axes(oldax);
end

function display_message( msg, fig )
persistent msgText

if nargin>1
    msgText = uicontrol(fig,'Style','Text','Units','points',...
        'Position',[10 10 1000 10],...
        'HorizontalAlignment','left',...
        'String','');
end

msgText.String = msg;
logmsg(msg)
end
