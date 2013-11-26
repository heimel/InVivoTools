function [outstim] = loadstim(PSstim)

PSstim = unloadstim(PSstim);
StimWindowGlobals;

% Set random seed
s = RandStream.create('mt19937ar','seed',PSstim.PSparams.seed);
RandStream.setDefaultStream(s);

% Initialize and find Images
filedir = PSstim.PSparams.dir;
prefix = PSstim.PSparams.prefix;
imgno = PSstim.PSparams.imgnumber;
blankpause = PSstim.PSparams.blankpause;
currentdir = pwd;
cd(filedir);
filenames_temp = dir;
cd(currentdir);

j = 1;
[x, y] = size(filenames_temp); 
for i=1:x
    isimage = strfind(filenames_temp(i).name,prefix);
    if isimage
        filenames(j,:) = filenames_temp(i).name(:);
        j = j + 1;
    end;
end;

[x, y] = size(filenames); 
imgperfile = zeros(x,1);
imgcumind = zeros(x, 1);
for i=1:x
    if ismac filename = [filedir '/' filenames(i,:)];
    else filename = [filedir '\' filenames(i,:)]; end;
    info = imfinfo(filename);
    imgperfile(i) = numel(info);
    if i==1 imgcumind(i) = 1;
    else imgcumind(i) = imgcumind(i-1) + imgperfile(i);
    end;
end;
imgcumind(i+1) = imgcumind(i-1) + imgperfile(i);
num_images = sum(imgperfile); % Total Number of Images in Folder 

remainingframes = imgno - 1;

% Generate Random Frame Index
randframes = randperm(num_images);
rfileind = zeros(imgno, 1);
rimgind = zeros(imgno, 1);
for k = 1:imgno
    for j=1:x
        if (randframes(k)>=imgcumind(j)) && (randframes(k)<imgcumind(j+1))
            rfileind(k) = j;
            rimgind(k) = randframes(k) - imgcumind(j) + 1;
            break;
        end;
    end;
end;

% Load first image as texture
if ismac A = imread([filedir '/' filenames(rfileind(1),:)], rimgind(1));
else A = imread([filedir '\' filenames(rfileind(1),:)], rimgind(1)); end;
imgtex = Screen('MakeTexture', StimWindow, A);
randlog = randframes(1);
frames = 1;

colors = pscolors(PSstim);

% Stimulus Variables
ds_userfield = struct('remainingframes', remainingframes, 'randlog', randlog, ...
               'randframes', randframes, 'imgnum', imgno, 'randfileind', rfileind, ...
               'randimgind', rimgind, 'filedir', filedir, 'filenames', filenames, ...
               'blankpause', blankpause, 'texid', imgtex);

% make color tables
offClut = ones(256,1)*colors.backdropRGB;
clut_bg = offClut;
clut_usage = ones(size(clut_bg)); % we'll claim we'll use all slots
clut = StimWindowPreviousCLUT; % we no longer need anything special here
clut(1,:) = colors.backdropRGB;

dp_stim = {'fps',1000/PSstim.PSparams.pause,'rect',PSstim.PSparams.rect,'frames',frames,PSstim.PSparams.dispprefs{:}};
DP_stim = displayprefs(dp_stim);
dS_stim = { 'displayType', 'Movie', 'displayProc', 'customdraw',  ...
         'offscreen', imgtex, 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
		 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_userfield};
PSstim = setdisplayprefs(PSstim,DP_stim);
outstim = PSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS_stim));
outstim.stimulus = loadstim(outstim.stimulus);
return;

