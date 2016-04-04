function [outstim] = loadstimPTB3(PSstim)
%PERIODICSTIM/LOADSTIMPTB3
%

PSstim = unloadstim(PSstim);

StimWindowGlobals;
% 
% [spatialphase, pixelIncrement, wLeng, destination_rect, ...
%     width_offscreen, height_offscreen] = spatial_phase(PSstim);

[img, frames, ds_userfield, destination_rect] = animate(PSstim);

colors = pscolors(PSstim);

%1 goes to max deflection above background bg +
%(chromehigh-chromelow)*light
%-1 goes to min deflection below background + (chromhigh-chromelow)*dark
%0 goes to background (chromlow+(chromehigh-chromelow)*background

img_colorized = cat(3,rescale(img,[-1 1],[colors.low_rgb(1) colors.high_rgb(1)]),...
	rescale(img,[-1 1],[colors.low_rgb(2) colors.high_rgb(2)]),...
	rescale(img,[-1 1],[colors.low_rgb(3) colors.high_rgb(3)]));
   
gratingtex = Screen('MakeTexture',StimWindow,img_colorized);

clut_bg = ones(256,1)*colors.backdropRGB;
clut_usage = ones(size(clut_bg)); % we'll claim we'll use all slots
clut = repmat(linspace(0,1,256)'*255,1,3);  

DP_stim = getdisplayprefs(PSstim);
DP_stim = setvalues(DP_stim,{'fps',StimWindowRefresh,'rect',destination_rect,'frames',frames});

dS_stim = { 'displayType', 'Movie', 'displayProc', 'standard', ...
         'offscreen', gratingtex, 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
		 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_userfield };
DS_stim = displaystruct(dS_stim);

ds_userfield = MovieParams2MTI(DS_stim,DP_stim);

ps_add_tex = [];

if isfield(PSstim.PSparams,'ps_add') && ~isempty(PSstim.PSparams.ps_add)
	[ps_add_image,ps_add_destrect,ds_adduserfield] = make_ps_add(PSstim.PSparams.ps_add);
	ps_add_tex = Screen('MakeTexture',StimWindow,ps_add_image);
	dS_add = {'displayType','Movie','displayProc','standard',...
		'offscreen',ps_add_tex,'frames',frames,'clut_usage',clut_usage,'depth',8,...
		'clut_bg',clut_bg,'clut',clut,'clipRect',[],'makeClip',0,'userfield',ds_adduserfield};
	DS_add = displaystruct(dS_add);
	dp_add = [{'fps',StimWindowRefresh,'rect',ps_add_destrect,'frames',frames} PSstim.PSparams.dispprefs];
	DP_add = displayprefs(dp_add);
	moviefields_add = MovieParams2MTI(DS_add,DP_add);
	ds_userfield = MovieParamsCat(ds_userfield,moviefields_add);
end

clip_tex = [];

fullscreen = (isnan(PSstim.PSparams.size)||isinf(PSstim.PSparams.size)) && ...
    PSstim.PSparams.rect(1)<=0 && ...
    PSstim.PSparams.rect(2)<=0 && ...
    PSstim.PSparams.rect(3)>=StimWindowRect(3) && ...
    PSstim.PSparams.rect(4)>=StimWindowRect(4);
    
if PSstim.PSparams.windowShape>-1 && ~fullscreen
	[clip_image,clip_dest_rect,ds_clipuserfield] = makeclippingrgn(PSstim);
	clip_tex = Screen('MakeTexture',StimWindow,clip_image);
	dS_clip = { 'displayType', 'Movie', 'displayProc', 'standard', ...
	         'offscreen', clip_tex, 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
			 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_clipuserfield };
	DS_clip = displaystruct(dS_clip);
	dp_clip = [{'fps',StimWindowRefresh,'rect',clip_dest_rect,'frames',frames},PSstim.PSparams.dispprefs];
	DP_clip = displayprefs(dp_clip);
	moviefields_clip = MovieParams2MTI(DS_clip,DP_clip);
	ds_userfield = MovieParamsCat(ds_userfield,moviefields_clip);
end;

ps_mask_tex = [];

if isfield(PSstim.PSparams,'ps_mask'),
	[ps_mask_image,ps_mask_destrect,ds_maskuserfield] = make_ps_mask(PSstim.PSparams.ps_mask);
	ps_mask_tex = Screen('MakeTexture',StimWindow,ps_mask_image);
	dS_mask = {'displayType','Movie','displayProc','standard',...
		'offscreen',ps_mask_tex,'frames',frames,'clut_usage',clut_usage,'depth',8,...
		'clut_bg',clut_bg,'clut',clut,'clipRect',[],'makeClip',0,'userfield',ds_maskuserfield};
	DS_mask = displaystruct(dS_mask);
	dp_mask = [{'fps',StimWindowRefresh,'rect',ps_mask_destrect,'frames',frames},PSstim.PSparams.dispprefs];
	DP_mask = displayprefs(dp_mask);
	moviefields_mask = MovieParams2MTI(DS_mask,DP_mask);
	ds_userfield = MovieParamsCat(ds_userfield,moviefields_mask);
end

dS = { 'displayType', 'Movie', 'displayProc', 'standard', ...
         'offscreen', [gratingtex ps_add_tex clip_tex ps_mask_tex], 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
	 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_userfield };

PSstim = setdisplayprefs(PSstim,DP_stim);
 
outstim = PSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);

return

