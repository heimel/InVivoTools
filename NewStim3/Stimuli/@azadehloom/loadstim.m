function stimout = loadstim(stim)



StimWindowGlobals;
tex = Screen('MakeTexture',StimWindow,0.6);

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

