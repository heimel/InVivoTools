function [img_rgba, destrect, ds_userfields] = makeclippingrgn(PSstim)

% MAKECLIPPINGRGN - Make a clipping region for a periodicstim
%
%  [CLIP_IMAGE, DEST_RECT, DS_USERFIELD] = MAKECLIPPINGRGN(PSSTIM)
%
%  This function returns the elements necessary for the clipping region
%  (that is, mask region) that LOADSTIM can use for its displaystruct
%  object.  See 'help periodicstim' for the meanings of the windowShape
%  parameter.
%
%  See also: PERIODICSTIM/LOADSTIM, DISPLAYSTRUCT

PSparams = PSstim.PSparams;
rect = PSparams.rect;  % this is the rect requested by the user
width=rect(3)-rect(1); height=rect(4)-rect(2);

% where are we going to draw on the screen?
[spatialphase, pixelIncrement, wLeng, destination_rect, width_offscreen, height_offscreen] = spatial_phase(PSstim);
width_offscreen = ceil(sqrt(2)*width_offscreen);
height_offscreen = ceil(sqrt(2)*height_offscreen);

destrect = CenterRect([0 0 width_offscreen height_offscreen],rect);

frames = temporal_phase(PSstim);

[X,Y] = meshgrid( [1:width_offscreen]-width_offscreen/2 , [1:height_offscreen]-height_offscreen/2);

colors = pscolors(PSstim);

img_rgba = [];

clear ds_userfields;

makeClip = 5;

img_rgba = cat(3,repmat(uint8(colors.backdropRGB(1)),width_offscreen,height_offscreen),...
	repmat(uint8(colors.backdropRGB(2)),width_offscreen,height_offscreen),...
	repmat(uint8(colors.backdropRGB(3)),width_offscreen,height_offscreen));

switch (PSparams.windowShape),
	case {0,2,4,6}, % rectangle
		img_rgba(:,:,4) = uint8( 1-(abs(X)<=height/2 & abs(Y)<=width/2));
	case {1,3,5,7}, % oval
		img_rgba(:,:,4) = uint8( 1-(((X.^2)/((0.5*height)^2) + (Y.^2)/((0.5*width)^2) ) <=1 ));
end;

 % angles
switch (PSparams.windowShape),
	case {0,1}, % oriented with screen
		ds_userfields.Movie_angles = repmat(90,1,length(frames));
	case {2,3,6,7}, % oriented with grating
		ds_userfields.Movie_angles = repmat(90-PSparams.angle,1,length(frames));
	case {4,5}, % oriented 90 degrees shifted
		ds_userfields.Movie_angles = repmat(180-PSparams.angle,1,length(frames));
end;

switch(PSparams.windowShape),
	case 6, % remove rectangular aperture
		img_rgba(:,:,4) = img_rgba(:,:,4).*unit8( 1-(abs(X)<=0.5*PSparams.aperture(1) & abs(Y)<=0.5*PSparams.aperture(2)));
	case 7, % remove oval aperture
		img_rgba(:,:,4) = img_rgba(:,:,4).*unit8( 1-(((X^2)/((0.5*PSparams.aperture(1))^2) + (Y.^2)/((0.5*PSparams.aperture(2))^2))<=1    ) );
end;

img_rgba(:,:,4) = img_rgba(:,:,4)*255;
