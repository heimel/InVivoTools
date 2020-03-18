function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI, capture_movie)
%CUSTOMDRAW of ADVANCEDFLYOVER
%
% 201X, Sven van den Burg, Azadeh Tafreshiha
% 201X-2019, Alexander Heimel
%

if nargin<4 || isempty(capture_movie)
    capture_movie = false;
end

NewStimGlobals % for pixels_per_cm and NewStimViewingDistance
StimWindowGlobals % for StimWindowRefresh

% screen_center_r2n_cm = [0 0 NewStimViewingDistance];
screen_pxl = [StimWindowRect(3) StimWindowRect(4)];

pixels_per_degree = tan(pi/(2 * 180)) * NewStimViewingDistance * pixels_per_cm * 2 ;
params = getparameters(stim);

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
    else
        center_obj_pxl(1) = screen_pxl(1)+ extent_pxl(1)/2;
    end
else
    if strcmp(params.start_position, 'left')
        center_obj_pxl(1) = stoppoint_pxl;
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
for current_frame = 1:n_frames
    if params.appear
        if strcmp(params.start_position, 'left')
            if center_obj_pxl(1) > stoppoint_pxl
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
        image_rect =[ topleft_pxl bottomright_pxl];
        Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
    else
        image_rect =[ topleft_pxl bottomright_pxl];
        Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
    end
    stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
    
    if capture_movie
        Screen('AddFrameToMovie', StimWindow);
        
        % also save single frame
        if current_frame == round(n_frames/2)
            imageArray = Screen('GetImage', StimWindow);
            imwrite(imageArray,fullfile(getdesktopfolder,['stimulus_frame' params.filename]),'png')
        end
    end
end % current_frame
if ~params.stay
    Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
    stamp = Screen('Flip', StimWindow);
end
stimduration =toc;
if abs(stimduration-params.duration)>0.01 % more than expected difference
    logmsg(['Stimulus took ' num2str(stimduration) ' s.']);
end
done = 1;
stamp = [];

