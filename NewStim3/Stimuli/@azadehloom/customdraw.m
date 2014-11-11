function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI)
StimWindowGlobals

screen_topleft_r2n_cm = [-33.5/2 13.5 50]; 
pixels_per_cm = 1280/33.5;

params = getparameters(stim);

n_frames = params.duration * StimWindowRefresh;  % should be in s and should be in stimulus definition (azadehloom)

center_r2n_cm =  params.center_r2n_cm; % position of object center in cm relative to nose%
velocity_cmpf = params.velocity_cmps / StimWindowRefresh;


dp = struct(getdisplaystruct(stim));

my_texture = dp.offscreen(1);
% image_rect = Screen('Rect',my_texture);

% window_rect = StimWindowRect;
% x_min = window_rect(1);
% x_max = window_rect(3);
% y_min = window_rect(2);
% y_max = window_rect(4);

% x_pos = mean([x_min x_max]);
% y_pos = mean([y_min y_max]);

stamp = Screen('Flip', StimWindow);
% prevstamp = stamp;

for current_frame = 1:n_frames
    % real world motion
    center_r2n_cm = center_r2n_cm + velocity_cmpf;
    topleft_cm = center_r2n_cm - [1 -1 1].*params.extent_cm/2;
    bottomright_cm = center_r2n_cm + [1 -1 1].*params.extent_cm/2;
    
    topleft_pxl = project2monitor(topleft_cm,screen_topleft_r2n_cm,pixels_per_cm);
    bottomright_pxl = project2monitor(bottomright_cm,screen_topleft_r2n_cm,pixels_per_cm);
    
    %    image_rect = CenterRectOnPoint(image_rect, x_pos, y_pos);
    image_rect =[ topleft_pxl bottomright_pxl];
    Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
    stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
    
% %    image_rect = ScaleRect(image_rect, image_scale_vel, image_scale_vel);
%    
%     if x_pos > x_max || x_pos < x_min
%         x_vel = -(x_vel);
%         x_pos = x_pos + x_vel;
%     end
%     if y_pos > y_max || y_pos < y_min
%         y_vel = -(y_vel);
%         y_pos = y_pos + y_vel;
%     end
%     if RectHeight(image_rect) > image_max_height && (image_scale_vel > 1)
%         image_scale_vel = 0;
%     end
end

done = 1;
stamp = [];

