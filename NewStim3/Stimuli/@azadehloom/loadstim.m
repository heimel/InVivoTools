function stimout = loadstim(stim)
StimWindowGlobals
NewStimGlobals

params = getparameters(stim);

if isempty(fileparts(params.filename)) % i.e. no path included
    filepath = fileparts(mfilename('fullpath'));
    filename = fullfile(filepath,params.filename);
else
    filename = params.filename;
end
[my_image, ~, alpha] = imread(filename);  
my_image(:,:,4) = alpha(:,:);
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

