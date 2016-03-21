function stimout = loadstim(stim)
%OPTOSTIM/LOADSTIM
%
% 2016, Alexander Heimel

StimWindowGlobals
NewStimGlobals

params = getparameters(stim);

% [my_image, ~, alpha] = imread(params.filename);  
% my_image(:,:,4) = alpha(:,:);
my_image = 0;
tex = Screen('MakeTexture', StimWindow, my_image, [], [], [], [], []);

if length(params.backdrop)==3
    clut_bg = params.backdrop*255;
else
    clut_bg = ones(1,3) * params.backdrop*255;
end
clut = repmat(linspace(0,1,256)'*255,1,3); 


dS_stim = { 'displayType', '', 'displayProc', 'customdraw', ...
         'offscreen', tex, 'frames', [], 'clut_usage', [], 'depth', 8, ...
'clut_bg', clut_bg, 'clut',clut, 'clipRect', [] , 'makeClip', 0,'userfield',[] };

DS_stim = displaystruct(dS_stim);

stimout = setdisplaystruct(stim,DS_stim);
stimout.stimulus = loadstim(stimout.stimulus);
