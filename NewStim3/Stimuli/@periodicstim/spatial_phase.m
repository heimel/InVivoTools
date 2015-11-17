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

if exist('NewStimViewingDistance','var') && ~isempty(NewStimViewingDistance)
    PSparams.distance = NewStimViewingDistance;
end

rect = PSparams.rect;  % this is the size requested by the user

if isfield(PSparams,'size') && ~isnan(PSparams.size) % use size to determine rect
    center = [ (rect(1)+rect(3))/2 (rect(2)+rect(4))/2 ];
    width = 2 * PSparams.distance * tan( PSparams.size /2 /360*2*pi) * pixels_per_cm * sqrt(2);
    height = 2 * PSparams.distance * tan( PSparams.size /2 /360*2*pi) * pixels_per_cm * sqrt(2);
    rect(1) = center(1) - width/2;
    rect(3) = center(1) + width/2;
    rect(2) = center(2) - height/2;
    rect(4) = center(2) + height/2;
end

width=rect(3)-rect(1); 
height=rect(4)-rect(2);

width_offscreen = ceil(sqrt(width^2 + height^2));
height_offscreen = ceil(sqrt(width^2 + height^2));
    
destination_rect = CenterRect([0 0 width_offscreen, height_offscreen],rect); % the location of the destination rect to be drawn to the screen

wLeng = (PSparams.distance * tan((pi/180))/PSparams.sFrequency) * pixels_per_cm;  % units: pixels per cycle
pixelIncrement = 2*pi/wLeng;

%
%spatialphase = mod( PSparams.sPhaseShift + (0:pixelIncrement:(width_offscreen-1)*pixelIncrement) , 2*pi);  % 1-D grating phase as a function of space
%

% Changged spatial phase behavior, to be consistent in the center of the
% stimulus. The contrast changes polarity at the center, and 0 and 180 degrees are different 2015-11-16 AH
spatialphase = mod( 0.5 * pi + PSparams.sPhaseShift + (0:pixelIncrement:(width_offscreen-1)*pixelIncrement) - (width_offscreen-1)/2*pixelIncrement , 2*pi);  % 1-D grating phase as a function of space

