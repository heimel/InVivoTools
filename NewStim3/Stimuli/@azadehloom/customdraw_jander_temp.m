function [done,stamp,stiminfo] = customdraw(stim, stiminfo, MTI)
%  = stim, stminfo, MTI
NewStimGlobals % for pixels_per_cm and NewStimViewingDistance
StimWindowGlobals % for StimWindowRefresh

screen_center_r2n_cm = [0 0 NewStimViewingDistance]; 
screen_pxl = [StimWindowRect(3) StimWindowRect(4)];
screen_cm = screen_pxl / pixels_per_cm;

% screen_center_r2n_cm = [0 0 100]; 
% screen_pxl = [StimWindowRect(3) StimWindowRect(4)];
% screen_cm = screen_pxl / pixels_per_cm;


params = getparameters(stim);
n_frames = params.duration * StimWindowRefresh + 1;  % should be in s and should be in stimulus definition (azadehloom)
center_r2n_cm =  params.center_r2n_cm; % position of object center in cm relative to nose%
velocity_cmpf = params.velocity_cmps / StimWindowRefresh;

dp = struct(getdisplaystruct(stim));
my_texture = dp.offscreen(1);

tic
Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
stamp = Screen('Flip', StimWindow);
for current_frame = 1:n_frames
    % real world motion
    if center_r2n_cm(3)>0 % i.e. in front of the viewer
        
        topleft_cm = center_r2n_cm - [1 -1 1].*params.extent_cm/2;
        bottomright_cm = center_r2n_cm + [1 -1 1].*params.extent_cm/2;
        
        topleft_pxl = project2monitor(topleft_cm, screen_center_r2n_cm,screen_pxl,screen_cm);
        bottomright_pxl = project2monitor(bottomright_cm, screen_center_r2n_cm,screen_pxl,screen_cm);
        
        image_rect =[ topleft_pxl bottomright_pxl];
        Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
    else
        Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
    end
    stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
    center_r2n_cm = center_r2n_cm + velocity_cmpf;
end
Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
Screen('Flip', StimWindow);
stimduration =toc;
Screen(StimWindow,'FillRect',dp.clut_bg(1,:)); % Change screen back to default background
stamp = Screen('Flip', StimWindow);

if abs(stimduration-params.duration)+0.01
    logmsg(['Stimulus took ' num2str(stimduration) ' s.']);
end
done = 1;
stamp = [];

