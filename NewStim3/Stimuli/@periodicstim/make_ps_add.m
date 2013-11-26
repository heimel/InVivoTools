function [img_rgba, destrect, ds_userfields] = make_ps_add(PSstim)

% MAKE_PS_ADD - Make a periodicstim to add to the primary stim
%
%  [IMAGE, DEST_RECT, DS_USERFIELD] = MAKE_PS_ADD(PSSTIM)
%
%  This function returns the elements necessary for the addition stim
%  that LOADSTIM can use for its displaystruct
%  object. 
%
%  See also: PERIODICSTIM/LOADSTIM, DISPLAYSTRUCT

PSparams = PSstim.PSparams;
rect = PSparams.rect;  % this is the rect requested by the user
width = rect(3)-rect(1); height=rect(4)-rect(2);

% where are we going to draw on the screen?
[spatialphase, pixelIncrement, wLeng, destination_rect, width_offscreen, height_offscreen] = spatial_phase(PSstim);
[img, frames, ds_userfields] = animate(PSstim);
colors = pscolors(PSstim);
img_rgba= cat(3,rescale(img,[-1 1],[colors.low_rgb(1) colors.high_rgb(1)]),...
        rescale(img,[-1 1],[colors.low_rgb(2) colors.high_rgb(2)]),...
        rescale(img,[-1 1],[colors.low_rgb(3) colors.high_rgb(3)]));
img_rgba(:,:,4) = 0.5*255;

destrect = destination_rect;
