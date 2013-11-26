function [img, frames, ds_userfield] = animate(PSstim)

% ANIMATE - create drawing sequence for periodicstim
%
%  [IMG, FRAMES, DS_USERFIELD] = ANIMATE(PSSTIM)
%
% Creates an image, frame numbers, and DISPLAYSTRUCT
% userfield items for animating a PERIODICSTIM.


PSparams = PSstim.PSparams;

 % SPATIAL PARAMETERS %%%%%%%%%
rect = PSparams.rect;  % this is the size requested by the user
width=rect(3)-rect(1); height=rect(4)-rect(2);
[spatialphase, pixelIncrement, wLeng, destination_rect, width_offscreen, height_offscreen] = spatial_phase(PSstim);

 % calculate TEMPORAL PARAMETERS %%%%%%%%%%%
tphase = temporal_phase(PSstim);

ds_userfield = [];

if PSparams.flickerType==0, c1 = 1; c2 = 0; elseif PSparams.flickerType==1, c1 = -1; c2 = 0; elseif PSparams.flickerType==2, c1 = 1; c2 = -1; end;

% we will use different animation schemes depending upon the animation type animType
switch PSparams.animType,
	case 0, % static
		img = c1*spatialphase2gratingimage(PSstim, spatialphase);
		tphase,
		frames = ones(size(tphase)); % always the first image
	case 1, % square
		spatialphase_ext = mod( PSparams.sPhaseShift + (0:pixelIncrement:(wLeng+width_offscreen)*pixelIncrement) , 2*pi);  % 1-D grating phase as a function of space
		img = c1*spatialphase2gratingimage(PSstim, spatialphase_ext);
		squarewave = rescale(round(double(sin(tphase)>0)),[0 1],[c2 c1]);
		ds_userfield.Movie_globalalphas = abs(squarewave); % 1 transmits the image, 0 if it should be masked out
		sourcerect_base = [0 0 width_offscreen height_offscreen];
		rectshift = double(squarewave<0)*pi*wLeng/(2*pi);
		ds_userfield.Movie_sourcerects = cat(3,(repmat(sourcerect_base,length(rectshift),1) + [rectshift' zeros(length(rectshift),1) rectshift' zeros(length(rectshift),1)])');
		frames = ones(size(tphase));
	case {2,3}, % sin wave, ramp
		if 0, % this is solution that involves multiple images for each contrast step needed; let's not use this one
			tphase = round(tphase * 10000)/10000; % round small differences
			unique_tphase = unique(tphase);
			if PSparams.animType==2, tphase_contrast = cos(unique_tphase);
			else, tphase_contrast = unique_tphase/(2*pi);
			end;
			tphase_contrast = rescale(tphase_contrast, [0 1],[c2 c1]);
			frames = zeros(1,length(tphase));
			for i=1:length(unique_tphase),
				img{i} = spatialphase2gratingimage(PSstim, tphase_contrast(i)*spatialphase);
				tphase_inds = find(tphase==unique_tphase(i));
				frames(tphase_inds) = i;
			end;
		else, % this is a solution that modulates the "global gamma" and uses a spatial phase shift of the source rectangle to modulate contrast;
			% make larger offscreen window, larger by 1 cycle
			spatialphase_ext = mod( PSparams.sPhaseShift + (0:pixelIncrement:(wLeng+width_offscreen)*pixelIncrement) , 2*pi);  % 1-D grating phase as a function of space
			img = c1*spatialphase2gratingimage(PSstim, spatialphase_ext);
			if PSparams.animType==2,
				tphase_contrast = cos(tphase);  % this won't work for counterphase
			else, tphase_contrast = tphase/(2*pi);
			end;
			ds_userfield.Movie_globalalphas = abs(tphase_contrast);
			sourcerect_base = [0 0 width_offscreen height_offscreen];
			rectshift = double((c2==-1)&(tphase_contrast<0))*pi*wLeng/(2*pi);
			ds_userfield.Movie_sourcerects = cat(3,(repmat(sourcerect_base,length(rectshift),1) + [rectshift' zeros(length(rectshift),1) rectshift' zeros(length(rectshift),1)])');
			frames = ones(size(tphase));
		end;
	case 4, % drifting grating
		% make larger offscreen window, larger by 1 cycle
		spatialphase_ext = mod( PSparams.sPhaseShift + (0:pixelIncrement:(wLeng+width_offscreen)*pixelIncrement) , 2*pi);  % 1-D grating phase as a function of space
		img = spatialphase2gratingimage(PSstim, spatialphase_ext);
		sourcerect_base = [0 0 width_offscreen height_offscreen];
		frames = ones(size(tphase));
		rectshift = tphase*wLeng/(2*pi); % translate temporal frequency shifts into spatial shifts in the offscreen window
		ds_userfield.Movie_sourcerects = cat(3,(repmat(sourcerect_base,length(rectshift),1) + [rectshift' zeros(length(rectshift),1) rectshift' zeros(length(rectshift),1)])');
	case 5, %fixed on duration for static stimulus
		img = c1*spatialphase2gratingimage(PSstim, spatialphase);
		frames = ones(1,ceil(PSparams.fixedDur*StimWindowRefresh)); % closest match to number of frames required
end;

ds_userfield.Movie_angles = repmat(90+PSparams.angle,1,length(frames));


