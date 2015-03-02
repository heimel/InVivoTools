function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI)
NewStimGlobals % for pixels_per_cm and NewStimViewingDistance
StimWindowGlobals % for StimWindowRefresh

% screen_center_r2n_cm = [0 0 NewStimViewingDistance];
screen_pxl = [StimWindowRect(3) StimWindowRect(4)];
NewStimViewingDistance = 30;
screen_cm = screen_pxl / pixels_per_cm;
pixels_per_degree = tan(pi/(2 * 180)) * NewStimViewingDistance * pixels_per_cm * 2 ;
params = getparameters(stim);
n_frames_expansion = params.expansiontime *StimWindowRefresh;
duration_trial = params.expansiontime + params.statictime;
n_frames = duration_trial * StimWindowRefresh + 1; % should be in s and should be in stimulus definition (azadehloom)
screen_center = screen_pxl / 2;
degreevelocity = (params.expanded_diameter - params.extent_degree(1))/ (2*n_frames_expansion) ;
pxlvelocity = degreevelocity * pixels_per_degree;
% center_r2n_cm =  params.center_r2n_cm; % position of object center in cm relative to nose%
%velocity_cmpf = params.velocity_cmps / StimWindowRefresh;

dp = struct(getdisplaystruct(stim));
my_texture = dp.offscreen(1);

tic
Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
stamp = Screen('Flip', StimWindow);


for current_cycle = 1:params.n_repetitions
    topleft_pxl_x = screen_center(1) - pixels_per_degree * params.extent_degree(1)/2;
    topleft_pxl_y = screen_center(2) - pixels_per_degree * params.extent_degree(2)/2;
    bottomright_pxl_x = screen_center(1) + pixels_per_degree * params.extent_degree(1)/2;
    bottomright_pxl_y = screen_center(2) + pixels_per_degree * params.extent_degree(2)/2;
    topleft_pxl = [topleft_pxl_x topleft_pxl_y];
    bottomright_pxl = [bottomright_pxl_x bottomright_pxl_y];
    
    for current_frame = 1:n_frames
        % real world motion
        %if center_r2n_cm(3)>0 % i.e. in front of the viewer
        
        %         topleft_cm = center_r2n_cm - [1 -1 1].*params.extent_cm/2;
        %         bottomright_cm = center_r2n_cm + [1 -1 1].*params.extent_cm/2;
        %
        %         topleft_pxl = project2monitor(topleft_cm, screen_center_r2n_cm,screen_pxl,screen_cm);
        %         bottomright_pxl = project2monitor(bottomright_cm, screen_center_r2n_cm,screen_pxl,screen_cm);
        if current_frame < n_frames_expansion
            topleft_pxl_x = topleft_pxl_x - pxlvelocity;
            topleft_pxl_y = topleft_pxl_y - pxlvelocity;
            bottomright_pxl_x = bottomright_pxl_x + pxlvelocity;
            bottomright_pxl_y = bottomright_pxl_y + pxlvelocity;
            topleft_pxl = [topleft_pxl_x topleft_pxl_y];
            bottomright_pxl = [bottomright_pxl_x bottomright_pxl_y];
        end
        
        image_rect =[ topleft_pxl bottomright_pxl];
        Screen('DrawTexture', StimWindow, my_texture, [], image_rect);
        %else
        %    Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
        % end
        stamp = Screen('Flip', StimWindow, stamp+0.5/StimWindowRefresh);
        %center_r2n_cm = center_r2n_cm + velocity_cmpf;
    end
    Screen(StimWindow,'FillRect',dp.clut_bg(1,:));
    stamp = Screen('Flip', StimWindow);
    pause(0.5);
end

stimduration =toc;
if abs(stimduration-duration_trial)+0.01
    logmsg(['Stimulus took ' num2str(stimduration) ' s.']);
end
done = 1;
stamp = [];

