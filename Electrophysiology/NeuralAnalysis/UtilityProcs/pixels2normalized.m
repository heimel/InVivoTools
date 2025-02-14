function newrect = pixels2normalized(fig,rect)

%  Part of the NeuralAnalysis package
%
%  NEWRECT = PIXELS2NORMALIZED(FIG, RECT)
%
%  Converts a rect in 'pixels' units to 'normalized' units (see 'help axes'
%  for definition).
%
%  See also:  NORMALIZED2PIXELS

b = get(fig,'position');
newrect = ([(rect(1)-1)/b(3) (rect(2)-1)/b(4) rect(3)/b(3) rect(4)/b(4)]);
