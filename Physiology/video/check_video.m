function check_video(file_path_and_name)
%CHECK_VIDEO.m
%
%-------------------------------------------------------------------------%
%
%       *** Very Beta ***
%
%   - opening and checking save data.
%
%   - contains analysing code.
%
%   Used scripts:
%       getfourcc()
%
%   Last edited 8-3-2016. SL
%
%   *** REVISION:
%           -> 
%           -> 
%
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% Initialisation
close all       % Close all current windows with figures (plots)
clc             % Clear Command window
%-------------------------------------------------------------------------%

% for debugging purpose
% show installed codec on system
logmsg('Show all installed codecs on system');disp(' ');disp(' ');
getfourcc;

% make sure file path and file are in correct syntax
file_open = fullfile(file_path_and_name);

% retrieve and show video meta-data
mmfileinfo(file_open)

% open video container
vid = VideoReader(file_open)
info_on_vid = get(vid);

% example
info_on_vid

% video = read(vid,[1 info_on_vid.NumberOfFrames]); % first 10 frames
video = read(vid,[1 10]); % first 10 frames

% % [X,Y,~,frames]=size(video)
% 4-D container (X,Y,Z,frame) Z = 1 or : 

% test = video(:,:,:); % 3D container
first_frame  = video(:,:,:,1);    % first frame
second_frame = video(:,:,:,2);    % second frame

% Otsu's method
graythresh(first_frame);

% show frame in test 
imshow(first_frame);



end