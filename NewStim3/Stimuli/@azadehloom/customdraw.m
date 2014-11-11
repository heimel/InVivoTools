function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI)
NewStimGlobals % for pixels_per_cm and NewStimViewingDistance
StimWindowGlobals % for StimWindowRefresh

screen_topleft_r2n_cm = [-33.5/2 13.5 NewStimViewingDistance]; 

params = getparameters(stim);
n_frames = params.duration * StimWindowRefresh;  % should be in s and should be in stimulus definition (azadehloom)
center_r2n_cm =  params.center_r2n_cm; % position of object center in cm relative to nose%
velocity_cmpf = params.velocity_cmps / StimWindowRefresh;

dp = struct(getdisplaystruct(stim));
my_texture = dp.offscreen(1);

for current_frame = 1:n_frames
    % real world motion
    center_r2n_cm = center_r2n_cm + velocity_cmpf;
    topleft_cm = center_r2n_cm - [1 -1 1].*params.extent_cm/2;
    bottomright_cm = center_r2n_cm + [1 -1 1].*params.extent_cm/2;
    
    topleft_pxl = project2monitor(topleft_cm,screen_topleft_r2n_cm,pixels_per_cm);
    bottomright_pxl = project2monitor(bottomright_cm,screen_topleft_r2n_cm,pixels_per_cm);
    
    image_rect =[ topleft_pxl bottomright_pxl];
    Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
    stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
end

done = 1;
stamp = [];

