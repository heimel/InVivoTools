function [spatialphase, pixelIncrement, wLeng, destination_rect, width_offscreen, height_offscreen] = spatial_phase(PSstim)

% SPATIAL_PHASE - Create spatial parameters for periodicstim
%
%  [SPATIALPHASE, PIXELINCREMENT, WLENG, DESTINATION_RECT,...
%     WIDTH_OFFSCREEN, HEIGHT_OFFSCREEN] = SPATIAL_PHASE(PSSTIM)
%
%  Returns spatial parameters for a PERIODICSTIM PSSTIM.
%
%  SPATIALPHASE - The phase value (between 0 and 2pi) for each
%  pixel in the image.
%
%  PIXELINCREMENT: the phase increment from pixel to pixel.
%
%  WLENG: the spatial cycle interval (in pixels/cycle)
%
%  DESTINATION_RECT: the location on the screen where the
%  rectangle should be drawn; note that this does not match
%  what the user requests, as we may have to create a larger
%  offscreen window so the grating can completely fill the
%  users requested space after any rotating.
%
%  WIDTH_OFFSCREEN: the width of the offscreen texture
%  HEIGHT_OFFSCREEN: the height of the offscreen texture
%  
%
%  See also: PERIODICSTIM

NewStimGlobals;

PSparams = PSstim.PSparams;

 % SPATIAL PARAMETERS %%%%%%%%%5
rect = PSparams.rect;  % this is the size requested by the user
width=rect(3)-rect(1); height=rect(4)-rect(2);

width_offscreen = ceil(max(width,height)*sqrt(2));  % this is the size of the offscreen texture
height_offscreen = ceil(max(width,height)*sqrt(2)); % this is the size of the offscreen texture

destination_rect = CenterRect([0 0 width_offscreen, height_offscreen],rect); % the location of the destination rect to be drawn to the screen

wLeng = (PSparams.distance * tan((pi/180)/PSparams.sFrequency)) * pixels_per_cm;  % units: pixels per cycle
pixelIncrement = 2*pi/wLeng;
spatialphase = mod( PSparams.sPhaseShift + (0:pixelIncrement:(width_offscreen-1)*pixelIncrement) , 2*pi);  % 1-D grating phase as a function of space

