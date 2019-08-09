function [frameRate, arena] = get_arena(filename, stimStart, record)
% GET_ARENA gets the position of the visible monitor screen from the user
%
%  [frameRate, arena] = get_arena(filename, stimStart, record)
%
% 2016, Azadeh Tafreshiha
% 2018-2019, Edited Alexander Heimel
%
% DEPRECATED, USE WC_GET_ARENA INSTEAD

v = VideoReader(filename);
frameRate = get(v, 'FrameRate');

try
    v.CurrentTime = stimStart;
    firstframe = readFrame(v);
catch % using legacy videoreader
    stimFrame = stimStart*frameRate;
    firstframe = read(v,stimFrame);
end
    
figure;
imshow(firstframe, []);
axis image on
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

filename2 = fullfile(experimentpath(record),'firstframe.mat');
save(filename2, 'firstframe');

title('Select the chamber arena region');

% roiR = getrect; % this is a classical method. which is also ok but the one bellow is better
h = imrect; % select a ROI in the frame
arena = getPosition(h);
close(gcf);
drawnow 
