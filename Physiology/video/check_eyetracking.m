
% correct for last trials
%pupil_framerate = 20; % Hz
pupil_timeshift = 0.2; % s

pupil_xy = load('pupil_xy.txt','-ascii');
pupil_area = load('pupil_area.txt','-ascii');
%pupil_t = (0:size(pupil_xy,1)-1)/pupil_framerate + pupil_timeshift;

pupil_t = (pupil_area(:,1)-pupil_area(1,1))/1e9 + pupil_timeshift;
stims = load('stims.mat');

figure
plot(pupil_t,pupil_xy(:,2));
hold on
plot_stimulus_timeline(stims)
