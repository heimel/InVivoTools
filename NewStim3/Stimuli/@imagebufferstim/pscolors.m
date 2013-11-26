function colors = pscolors(PSstim)

% PSCOLORS - the colors for a periodicstim stimulus
%
%   COLORS = PSCOLORS(PSSTIM)
%
%    Returns the background, backdrop, and max
%    offset high and max offset low colors for a
%    periodicstim.
%
%    The values are returned on a 0-1 "luminance" scale
%    as well as in RGB.
%
% See also: PERIODICSTIM
%
 
PSparams = PSstim.PSparams;
  
midpoint = PSparams.background;
maxOffset = min ( (abs(1-midpoint)), abs(midpoint) );
darkoffset = -maxOffset*PSparams.contrast; % "luminance" of darkest shade
lightoffset = +maxOffset*PSparams.contrast; % "luminance" of brightest shade

middle_rgb = PSparams.chromlow+(PSparams.chromhigh-PSparams.chromlow)*midpoint;
low_rgb = middle_rgb + (PSparams.chromhigh-PSparams.chromlow)*darkoffset;
high_rgb = middle_rgb + (PSparams.chromhigh-PSparams.chromlow)*lightoffset;

backdropRGB = PSparams.chromlow+(PSparams.chromhigh-PSparams.chromlow)*PSparams.background;

clear PSparams PSstim;

colors = workspace2struct;
