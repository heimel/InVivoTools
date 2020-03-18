function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI, capture_movie)
NewStimGlobals % for pixels_per_cm and NewStimViewingDistance
StimWindowGlobals % for StimWindowRefresh

% screen_center_r2n_cm = [0 0 NewStimViewingDistance];
screen_pxl = [StimWindowRect(3) StimWindowRect(4)];
screen_cm = screen_pxl / pixels_per_cm;

pixels_per_degree = tan(pi/(2 * 180)) * NewStimViewingDistance * pixels_per_cm * 2 ;
params = getparameters(stim);

n_frames = params.duration * StimWindowRefresh + 1; % should be in s and should be in stimulus definition (azadehloom)
screen_center = screen_pxl / 2;
pxlvelocity = params.velocity_degps * pixels_per_degree;
velocity_pxlpf = pxlvelocity / StimWindowRefresh;

extent_pxl = params.extent_deg * pixels_per_degree;

n_frames = params.duration * StimWindowRefresh + 1;  % should be in s and should be in stimulus definition (azadehloom)
center_obj_pxl =  screen_center; % position of object center in degrees, default is at center of screen

stoppoint_pxl = params.stoppoint * pixels_per_degree;
if params.appear
    
    if strcmp(params.start_position, 'left')
        center_obj_pxl(1) = - extent_pxl(1)/2;
    elseif strncmpi(params.start_position,'top',3)
        center_obj_pxl(2) = - extent_pxl(2)/2;
    elseif strcmp(params.start_position, 'far')
        center_obj_pxl(2) = - extent_pxl(2)/2;
        center_obj_pxl(1) = 40;
    else
        center_obj_pxl(1) = screen_pxl(1)+ extent_pxl(1)/2;
    end
else
    if strcmp(params.start_position, 'left')
        center_obj_pxl(1) = stoppoint_pxl;
    elseif strncmpi(params.start_position,'top',3) || strcmp(params.start_position, 'far')
        center_obj_pxl(2) = stoppoint_pxl;
    else
        center_obj_pxl(1) = screen_pxl(1) - stoppoint_pxl;
    end
end

topleft_pxl = center_obj_pxl - extent_pxl/2;
bottomright_pxl = center_obj_pxl + extent_pxl/2;

dp = struct(getdisplaystruct(stim));
my_texture = dp.offscreen(1);

tic
stamp = Screen('Flip', StimWindow);
stopped = 0;

if strcmp(params.start_position, 'top_opto')
    StimSerialGlobals
    StimSerial('rts',StimSerialStim,1);
end

for current_frame = 1:n_frames
    if params.appear
        if strcmp(params.start_position, 'left')
            if center_obj_pxl(1) > stoppoint_pxl
                stopped = 1;
            end
        elseif strncmpi(params.start_position,'top',3) || strcmp(params.start_position, 'far')
            if center_obj_pxl(2) > stoppoint_pxl
                stopped = 1;
            end
        else
            if center_obj_pxl(1) < screen_pxl(1) - stoppoint_pxl
                stopped = 1;
            end
        end
    elseif params.stay
        if strcmp(params.start_position, 'left')
            if center_obj_pxl(1) > screen_pxl(1) - stoppoint_pxl
                stopped = 1;
            end
        elseif strncmpi(params.start_position,'top',3) || strcmp(params.start_position, 'far')
            if center_obj_pxl(2) > screen_pxl(2) - stoppoint_pxl
                stopped = 1;
            end
        else
            if center_obj_pxl(1) < stoppoint_pxl
                stopped = 1;
            end
        end
    end
    
    
    if ~stopped
        
        center_obj_pxl = center_obj_pxl + velocity_pxlpf;
        topleft_pxl = topleft_pxl + velocity_pxlpf;
        bottomright_pxl = bottomright_pxl + velocity_pxlpf;
    end
    
    for im = 1:length(params.dot_distance)
         %get extra location if it exists
        if ~isnan(params.dot_distance(im))
            pre_rect =[topleft_pxl bottomright_pxl];
            pxdist = params.dot_distance(im) * pixels_per_degree;
            pre_rect([1 3]) = pre_rect([1 3]) + pxdist;
            image_rect = pre_rect;
            Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
        end
    end
    
    stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
    
end

if strcmp(params.start_position, 'top_opto')
    StimSerial('rts',StimSerialStim,0);
end

if ~params.stay
    Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
    stamp = Screen('Flip', StimWindow);
end
stimduration =toc;
if abs(stimduration-params.duration)+0.01
    logmsg(['Stimulus took ' num2str(stimduration) ' s.']);
end
done = 1;
stamp = [];

