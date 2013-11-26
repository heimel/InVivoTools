function [outstim] = loadstim(cms)

StimWindowGlobals;

cms = unloadstim(cms);

p = getparameters(cms);

do = getDisplayOrder(p.script);

if ~isloaded(p.script),
	p.script = loadStimScript(p.script);
end;

ds_userfield.Movie_textures = [];
ds_userfield.Movie_sourcerects = [];
ds_userfield.Movie_destrects = [];
ds_userfield.Movie_angles = [];
ds_userfield.Movie_globalalphas= [];

offscreens = [];

clut = [zeros(3,256)]; clut_bg = [zeros(3,256)]; clut_usage = [1:256]; depth = 8; rect = [ 0 0 1 1];
fps = StimWindowRefresh;

for i=1:length(do),
	stim = get(p.script,do(i));
	ds_stim = getdisplaystruct(stim);
	dp_stim = getdisplayprefs(stim);
	new_ds_userfield = MovieParams2MTI(ds_stim, dp_stim);
	ds_userfield = MovieParamsAdd(ds_userfield, new_ds_userfield);
	dsstruct = struct(ds_stim);
	dpstruct = struct(dp_stim);
	offscreens = cat(1,offscreens(:),dsstruct.offscreen(:));
	if i==1, % just grab a few things
		clut = dsstruct.clut;
		clut_bg = dsstruct.clut_bg;
		depth = dsstruct.depth;
		fps = dpstruct.fps;
		rect = dpstruct.rect;
	end;
end;

dS = { 'displayType', 'Movie', 'displayProc', 'standard', ...
         'offscreen', offscreens, 'frames', 1:length(ds_userfield.Movie_textures), 'clut_usage', clut_usage, 'depth', 8, ...
	 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',ds_userfield };

dP = {'fps',fps,'rect',rect,'frames',1:length(ds_userfield.Movie_textures), p.dispprefs{:}};


cms = setdisplaystruct(cms,displaystruct(dS));
cms = setdisplayprefs(cms,displayprefs(dP));
 
outstim = cms;
outstim.stimulus = loadstim(outstim.stimulus);


