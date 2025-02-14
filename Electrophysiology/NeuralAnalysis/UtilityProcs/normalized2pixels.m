function newrect = normalized2pixels(fig, rect)

%  Part of the NeuralAnalysis package
%
%  NEWRECT = NORMALIZED2PIXELS(FIG,RECT)
%
%  Converts a 'normalized' rectangle (see help axes for definition) to raw
%  pixels.
%
%  See also:  PIXELS2NORMALIZED

b = get(fig,'position');
newrect=round([ rect(1)*b(3)+1 rect(2)*b(4)+1 rect(3)*b(3) rect(4)*b(4)]);
