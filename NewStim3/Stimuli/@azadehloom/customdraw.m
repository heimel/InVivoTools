function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI)
StimWindowGlobals

% should be in azadehloom
n_frames = 900;  % should be in s and should be in stimulus definition (azadehloom)
x_vel = 3; %in pixel per frame, should be in deg/s or cm/s and should be in stim def
% in loadstim (or here) translation to pixels/per/frame
y_vel = 3; %in pixel per frame, should be in deg/s or cm/s and should be in stim def
image_max_height = 1000; % should be in deg, 
image_scale_vel = 1.01; % should be in deg/s or cm/s approach velocity


dp = struct(getdisplaystruct(stim));

my_texture = dp.offscreen(1);
image_rect = Screen('Rect',my_texture);

window_rect = StimWindowRect;
x_min = window_rect(1);
x_max = window_rect(3);
y_min = window_rect(2);
y_max = window_rect(4);

x_pos = mean([x_min x_max]);
y_pos = mean([y_min y_max]);

Screen('BlendFunction', StimWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
stamp = Screen('Flip', StimWindow);
prevstamp = stamp;

for current_frame = 1:n_frames
    image_rect = CenterRectOnPoint(image_rect, x_pos, y_pos);
    Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
    stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
  % stamp = Screen('Flip', StimWindow);
   
   % disp(1/(stamp-prevstamp))
   prevstamp = stamp;
    
    x_pos = x_pos + x_vel;
    y_pos = y_pos + y_vel;
    image_rect = ScaleRect(image_rect, image_scale_vel, image_scale_vel);
    
     if x_pos > x_max || x_pos < x_min
         x_vel = -(x_vel);
         x_pos = x_pos + x_vel;
     end
     if y_pos > y_max || y_pos < y_min
         y_vel = -(y_vel);
         y_pos = y_pos + y_vel;
     end
    if RectHeight(image_rect) > image_max_height && (image_scale_vel > 1)
        image_scale_vel = 0;
    end
end

done = 1;
stamp = [];

