function [frameRate, arena] = get_arena(filename, stimStart, record)
% gets the position of the visible monitor screen from the user
% March 2016, Azadeh

v = VideoReader(filename);
frameRate = get(v, 'FrameRate');
stimFrame = stimStart*frameRate;
firstframe = read(v,stimFrame); % read a frame at the beginning. 
figure;
imshow(firstframe, []); % just show it
axis on;
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
message1 = sprintf('Select the chamber arena region.');

%save frame1 as firstframe.mat 
filename2 = fullfile(experimentpath(record),'firstframe.mat');
save(filename2, 'firstframe');

% message1=msgbox('Select the chamber arena region.');
% set(message1, 'Position', [100 100 100 100])
h = msgbox(message1); set (h, 'Position', [390 388 130 53]); 
% [distance from left, distance from bottom, width, height]
uiwait(h);
% roiR = getrect; % this is a classical methid. which is also ok but the one bellow is better
h = imrect; % select a ROI in the frame
arena = getPosition(h);
fig = gcf;
close(fig)
drawnow %prioritize the graphics execution
end