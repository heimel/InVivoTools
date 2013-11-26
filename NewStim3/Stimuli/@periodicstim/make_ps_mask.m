function [img_rgba, destrect, ds_userfields] = make_ps_mask(PSstim)

% MAKE_PS_MASK - Make a clipping region with a mask that is itself a periodicstim
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
[img, frames, ds_userfields] = animate(PSstim);
colors = pscolors(PSstim);
img_rgba = uint8(cat(3,colors.backdropRGB(1)*ones(size(img)),colors.backdropRGB(2)*ones(size(img)),colors.backdropRGB(3)*ones(size(img))));
img_rgba(:,:,4) = 255 * img;

destrect = destination_rect;
