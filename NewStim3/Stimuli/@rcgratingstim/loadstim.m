function [outstim] = loadstim(RCGstim)

RCGstim = unloadstim(RCGstim);

StimWindowGlobals;

p = getparameters(RCGstim);

psb = p.baseps;
psbp = getparameters(psb);

 % animtype
psbp.tFrequency = 1/p.dur;
psbp.nCycles = 1;

dotest = 0;

if isfield(p, 'test'),
	if p.test,
		dotest = 1;
	end;
end;

colors = pscolors(p.baseps);

[spatialphase, pixelIncrement, wLeng, destination_rect, width_offscreen, height_offscreen] = spatial_phase(p.baseps);

offscreens = [];

stim.Movie_sourcerects = [];
stim.Movie_destrects = [];
stim.Movie_angles = [];
stim.Movie_globalalphas = [];
stim.Movie_textures = {};

     % if this code changes such that the order changes, then getstimvalues.m must change, too
for sf=1:length(p.spatialfrequencies),
	for sp=1:length(p.spatialphases),
		psbp.sFrequency = p.spatialfrequencies(sf);
		psbp.sPhaseShift = p.spatialphases(sp);
		ps = periodicstim(psbp);
		[img, frames, ds_userfield] = animate(ps); % reduce to a single frame
		img_colorized = cat(3,rescale(img,[-1 1],[colors.low_rgb(1) colors.high_rgb(1)]),...
		        rescale(img,[-1 1],[colors.low_rgb(2) colors.high_rgb(2)]),...
		        rescale(img,[-1 1],[colors.low_rgb(3) colors.high_rgb(3)]));
		offscreens(end+1) = Screen('MakeTexture',StimWindow,img_colorized);
		for o=1:length(p.orientations),
			stim.Movie_sourcerects(:,end+1,1) = ds_userfield.Movie_sourcerects(:,1,1);
			stim.Movie_destrects(:,end+1,1) = destination_rect;
			stim.Movie_angles(end+1) = 90+p.orientations(o);
			stim.Movie_globalalphas(end+1) = 1;
			if (dotest & ((o>1)|(sf>1)|(sp>1))), stim.Movie_globalalphas(end) = 0; end;
			stim.Movie_textures{end+1} = length(offscreens);
		end;
	end;
end;
 
% blank
psbp.contrast = 0;
ps = periodicstim(psbp);
colors = pscolors(ps);
[img, frames, ds_userfield] = animate(ps); % reduce to a single frame
img_colorized = cat(3,rescale(img,[-1 1],[colors.low_rgb(1) colors.high_rgb(1)]),...
        rescale(img,[-1 1],[colors.low_rgb(2) colors.high_rgb(2)]),...
        rescale(img,[-1 1],[colors.low_rgb(3) colors.high_rgb(3)]));
offscreens(end+1) = Screen('MakeTexture',StimWindow,img_colorized);
stim.Movie_sourcerects(:,end+1,1) = ds_userfield.Movie_sourcerects(:,1,1);
stim.Movie_destrects(:,end+1,1) = destination_rect;
stim.Movie_angles(end+1) = p.orientations(o);
stim.Movie_globalalphas(end+1) = 0;
stim.Movie_textures{end+1} = length(offscreens);

stim.clip_tex = [];
stim.clip_source = [];
stim.clip_dest = [];
stim.clip_angle = [];
stim.clip_globalalpha = [];
 % mask, if necessary
if psbp.windowShape>-1,
        [clip_image,clip_dest_rect,ds_clipuserfield] = makeclippingrgn(ps);
        stim.clip_tex = Screen('MakeTexture',StimWindow,clip_image);
	stim.clip_source = [0 0 size(clip_image,1) size(clip_image,2)];
	stim.clip_dest = clip_dest_rect;
	stim.clip_angle = ds_clipuserfield.Movie_angles(1);
	stim.clip_globalalpha = 1;
end;

offscreens(end+1) = stim.clip_tex;


numNonBlank = length(p.spatialfrequencies)*length(p.spatialphases)*length(p.orientations);

dO = getdisplayorder(RCGstim);

stim.frames = dO;
stim.numNonBlank = numNonBlank;
stim.blank = numNonBlank+1;
stim.pauseduration = max([1 round(p.dur*StimWindowRefresh)]);
stim.blankduration = max([1 round(p.pausebetweenreps*StimWindowRefresh)]);
stim.pauseRefresh = ones(1,length(dO)) * stim.pauseduration;
blanks = find(dO==stim.blank);
stim.pauseRefresh(blanks) = stim.blankduration;

offClut = ones(256,1)*colors.backdropRGB;
clut_bg = offClut;
clut_usage = ones(size(clut_bg)); % we'll claim we'll use all slots
clut = StimWindowPreviousCLUT; % we no longer need anything special here
clut(1,:) = colors.backdropRGB;

dp_stim = {'fps',StimWindowRefresh,'rect',destination_rect,'frames',1,p.dispprefs{:}};
dS = { 'displayType', 'MovieCustom', 'displayProc', 'customdraw', ...
         'offscreen', offscreens, 'frames', frames, 'clut_usage', clut_usage, 'depth', 8, ...
	 'clut_bg', clut_bg, 'clut', clut, 'clipRect', [] , 'makeClip', 0,'userfield',stim};

RCGstim = setdisplayprefs(RCGstim,displayprefs(dp_stim));
RCGstim = setdisplaystruct(RCGstim,displaystruct(dS));
outstim = RCGstim;
outstim.stimulus = loadstim(outstim.stimulus);
