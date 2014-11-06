function st = azadehloom( params )
if nargin<1 || ischar(params)
    params = [];
    params.filename = '1cm_cross.png';
    params.starting_position_relscreen = [0 0.5]; %
    params.velocity = [1 2]; % deg/s x and y
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