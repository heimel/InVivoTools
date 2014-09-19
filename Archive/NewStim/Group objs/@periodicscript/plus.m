function c = plus(a,b)

%  PERIODICSCRIPT/PLUS Add two periodicscripts
%
%  C = PLUS(A,B)
%
%  'Adds' the periodicscripts A and B.  This involves adding all of the stimuli
%  in B to A and updates the parameters.  Note that the display order is reset
%  to the default.  (This is necessary in order to preserve the relationship
%  between the periodicscript parameters and the stimuli in the script.)
% 
%  See also:  SETDISPLAYMETHOD

p1 = getparameters(a);
p2 = getparameters(b);

if (p1.imageType~=p2.imageType)|(p1.animType~=p2.animType)|...
		(p1.flickerType~=p2.flickerType)|~eqlen(p1.rect,p2.rect)|...
		~eqlen(p1.chromhigh,p2.chromhigh)|~eqlen(p1.chromlow,p2.chromlow)|...
		(p1.windowShape~=p2.windowShape),
	error(['these periodicscripts cannot be added'...
	       '--they differ in fundamental parameters']);
end;

p = p1;

p.angle = union(p1.angle,p2.angle);
p.sFrequency = union(p1.sFrequency,p2.sFrequency);
p.tFrequency = union(p1.tFrequency,p2.tFrequency);
p.nCycles = union(p1.nCycles,p2.nCycles);
p.contrast = union(p1.contrast,p2.contrast);
p.background = union(p1.background,p2.background);
p.backdrop = union(p1.backdrop,p2.backdrop);
p.nSmoothPixels= union(p1.nSmoothPixels,p2.nSmoothPixels);
p.barColor= union(p1.barColor,p2.barColor);
p.barWidth= union(p1.barWidth,p2.barWidth);
p.sPhaseShift= union(p1.sPhaseShift,p2.sPhaseShift);
p.fixedDur= union(p1.fixedDur,p2.fixedDur);

c = periodicscript(p);
