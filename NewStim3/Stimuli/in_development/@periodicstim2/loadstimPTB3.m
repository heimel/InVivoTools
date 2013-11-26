function [outstim] = loadstimPTB3(PSstim)

PSstim = unloadstim(PSstim);

StimWindowGlobals;

  % create a clipping region

 % SPATIAL PARAMETERS %%%%%%%%%
[spatialphase, pixelIncrement, wLeng, destination_rect, width_offscreen, height_offscreen] = spatial_phase(PSstim);
 % END OF SPATIAL PARAMETERS %%%%%%%%%%

 %%%%%%%% animation parameters

[img, frames, ds_userfield] = animate(PSstim);

 % contrast/color parameters

colors = pscolors(PSstim);

%1 goes to max deflection above background bg + (chromehigh-chromelow)*light
%-1 goes to min deflection below background + (chromhigh-chromelow)*dark
%0 goes to background (chromlow+(chromehigh-chromelow)*background

img_colorized = cat(3,rescale(img,[-1 1],[colors.low_rgb(1) colors.high_rgb(1)]),...
	rescale(img,[-1 1],[colors.low_rgb(2) colors.high_rgb(2)]),...
	rescale(img,[-1 1],[colors.low_rgb(3) colors.high_rgb(3)]));

gratingtex = Screen('MakeTexture',StimWindow,img_colorized);

 % make color tables

offClut = ones(256,1)*colors.backdropRGB;
clut_bg = offClut;
clut_usage = ones(size(clut_bg)); % we'll claim we'll use all slots
clut = StimWindowPreviousCLUT; % we no longer need anything special here
clut(1,:) = colors.backdropRGB;

dp = {'fps',StimWindowRefresh,'rect',destination_rect,'frames',frames,PSstim.PSparams.dispprefs{:} };
DP_stim = displayprefs(dp);
dS = { 'displayType', 'Movie', 'displayProc', 'standard', ...
         'offscreen', gratingtex, 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
		 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_userfield };
DS_stim = displaystruct(dS);

moviefields_stim = MovieParams2MTI(DS_stim,DP_stim);

[clip_image,clip_dest_rect,ds_clipuserfield] = makeclippingrgn(PSstim);
clip_tex = Screen('MakeTexture',StimWindow,clip_image);
dS_clip = dS; dS_clip{6} = clip_tex; dS_clip{22} = ds_clipuserfield;
DS_clip = displaystruct(dS_clip);
dp_clip = dp; dp_clip{4} = ceil(clip_dest_rect);
DP_clip = displayprefs(dp_clip);
moviefields_clip = MovieParams2MTI(DS_clip,DP_clip);

ds_userfield = MovieParamsCat(moviefields_stim,moviefields_clip);

dS = { 'displayType', 'Movie', 'displayProc', 'standard', ...
         'offscreen', [gratingtex clip_tex], 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
		 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_userfield };


PSstim = setdisplayprefs(PSstim,displayprefs(dp));
 
outstim = PSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);


return;

