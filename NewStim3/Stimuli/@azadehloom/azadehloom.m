function st = azadehloom( params )
if nargin<1 || ischar(params)
    params = [];
    params.filename = '1cm_cross.png';
    params.center_r2n_cm = [0 0 1000]; % position of object center in cm relative to nose%
    params.velocity_cmps = [0 0 -100]; % vx,vy,vz in cm/s, right and up and away are positive
    params.duration = 10; % duration of movement in s
    params.extent_cm = [10 10 0]; % extent in real world in cm
end

NewStimListAdd('azadehloom');

s = stimulus(5);
data = struct('params', params);
st = class(data,'azadehloom',s);
st.stimulus = setdisplayprefs(st.stimulus,displayprefs);




% 
% StimWindowGlobals;
% tex = Screen('MakeTexture',StimWindow,0.6);
% 
% colors = pscolors(periodicstim('default'));
% clut_bg = ones(256,1)*colors.backdropRGB;
% clut = repmat(linspace(0,1,256)'*255,1,3); 
% 
% 
% dS_stim = { 'displayType', 'ALEXANDER', 'displayProc', 'customdraw', ...
%          'offscreen', tex, 'frames', [], 'clut_usage', [], 'depth', 8, ...
% 'clut_bg', clut_bg, 'clut',clut, 'clipRect', [] , 'makeClip', 0,'userfield',[] };
% 
% DS_stim = displaystruct(dS_stim);
% 
% stim = setdisplaystruct(st,DS_stim);
% 
% df = displayprefs;
% stim = setdisplayprefs(stim,df);

%stim = loadstim( stim );