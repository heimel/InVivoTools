function stimout = loadstim(stim)
StimWindowGlobals
NewStimGlobals

params = getparameters(stim);

% making texture should be in loadstim
[my_image, ~, alpha] = imread(params.filename);  
my_image(:,:,4) = alpha(:,:);
tex = Screen('MakeTexture', StimWindow, my_image, [], [], [], [], []);

colors = pscolors(periodicstim('default'));
clut_bg = ones(256,1)*colors.backdropRGB;
clut = repmat(linspace(0,1,256)'*255,1,3); 


dS_stim = { 'displayType', 'ALEXANDER', 'displayProc', 'customdraw', ...
         'offscreen', tex, 'frames', [], 'clut_usage', [], 'depth', 8, ...
'clut_bg', clut_bg, 'clut',clut, 'clipRect', [] , 'makeClip', 0,'userfield',[] };

DS_stim = displaystruct(dS_stim);

stimout = setdisplaystruct(stim,DS_stim);

% df = displayprefs;
% stim = setdisplayprefs(stim,df);


stimout.stimulus = loadstim(stimout.stimulus);

