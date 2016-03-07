function check_video()
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
%   - getfourcc()
%
%   Last edited 7-3-2016. SL
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

getfourcc;

file_open = fullfile(save_to);

mmfileinfo(file_open);
vid = VideoReader(file_open)

info_on_vid = get(vid);
info_on_vid.NumberOfFrames;

% video = read(vid,[1 info_on_vid.NumberOfFrames]); % first 10 frames
video = read(vid,[1 10]); % first 10 frames

[X,Y,~,frames]=size(video)
% 4-D container (X,Y,Z,frame) Z = 1 or : 

% test = video(:,:,:); % 3D container
first_frame  = video(:,:,:,1);    % first frame
second_frame = video(:,:,:,2);    % second frame

% Otsu's method
graythresh(first_frame);

% show frame in test 
imshow(first_frame);



end