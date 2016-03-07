% open_grab.m
%-------------------------------------------------------------------------%
%
%   
%
%
%
%   Last edited 6-3-2016. SL
%
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

[ block_number, data_dir] = load_reference

% recording time is number of blocks (10 sec each) + an additional second
time = (block_number * 10) + 1; % recording time in seconds

% replace later with correct directory
% *** Beta ***
% data_dir  = 'D:\Software\temp';

% replace with acqReady
% *** Beta ***
read_data = fullfile(data_dir,'acqReady_tmp');


% set file output name
file_str = 'pupil_mouse.avi';

% read data from acqReady
tmp = importdata(read_data);
% retrieve data save directory
str  = char(tmp(2));

% strip  data save directory with \ as delimiter
save_path_cell = textscan(str,'%q','Delimiter','\');
save_path_cell = save_path_cell{1};

% get number of directories incl drive
[ind, ~] = size(save_path_cell);

% loop to reconstruct save directory with \\ instead of \
% mandatory for running the grabavi executable
for i = 1:ind

    save_path = char(save_path_cell(i));
    sep = '\\';
    
    if i == 1 && i <= ind
    save_to = strcat(save_path,sep);
    elseif i >= 1 &&  i <= ind
    save_to = strcat(save_to,save_path,sep);
    elseif i == ind
    save_to = strcat(save_to,save_path);
    end
    
end

% add the output name to the save directory
save_to = [save_to file_str];

% set executable name
run_exe = 'grabavi ';

% set recording time
rec_time = num2str(time);

% set final command to run
run_this = [run_exe rec_time ' ' save_to]
 
% go to executable directory
cd D:\Dropbox\NIN\grabbing_software\grabavi\Debug;

% run video executable
[~,cmdout] = system(run_this);

% output command-line info from executable
disp(cmdout);

% go back to original direcory (if needed?)
cd d:\dropbox\nin\grabbing_software



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