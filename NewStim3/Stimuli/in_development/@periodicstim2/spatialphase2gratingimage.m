function grating = spatialphase2gratingimage(ps, phase)

% SPATIALPHASE2GRATINGIMAGE - periodicstim helper, applies the image type
%
%  GRATING = SPATIALPHASE2GRATINGIMAGE(PS, PHASE)
%
%  Applies the image type to the grating phase (which varies between 0 and 2pi)
%
%  The resulting grating varies between -1 and 1.
%
%  See 'help periodicstim' for a list of image types and their meanings
%
 
switch ps.PSparams.imageType,
	case 0,  % field
		grating = 1;
	case 1, % square wave
		grating = -1+2*double(cos(phase)>0);
	case 2, % sine wave
		grating = cos(phase);
	case 3, % triangle
		grating = -1+2*(abs(phase - pi)/pi);
	case 4, % light saw
		grating = -1+2*(2*pi-phase)/(2*pi);
	case 5, % dark saw
		grating = -1+2*phase/(2*pi);
	case 6, % bars
		grating = double(phase<(ps.PSparams.barWidth*2*pi))*2*(ps.PSparams.barColor-0.5);
	case 7, % edge, like lightsaw but with bars determining width of saw
		phasemod = phase;
		phasemod(find(phase<ps.PSparams.barWidth*2*pi)) = 0;
		nonzerovalues = find(phase>=ps.PSparams.barWidth*2*pi);
		phasemod(nonzerovalues) = 1-rescale(phase(nonzerovalues),[min(phase(nonzerovalues)) max(phase(nonzerovalues))],[0 1]);
		grating = phasemod;
	case 8, % bump (bars with internal smooth dark->light->dark transitions (sinusoidal)
		phasemod = phase;
		phasemod(find(phase>=ps.PSparams.barWidth*2*pi)) = 0;
		phasemod = sin(-pi/2+2*pi*phasemod./max(phasemod));
		phasemod(find(phase>=ps.PSparams.barWidth*2*pi)) = 0;
		grating = phasemod;
	otherwise,
		error(['Unknown image type imageType']);
end;
