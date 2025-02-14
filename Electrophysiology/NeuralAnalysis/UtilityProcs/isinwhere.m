function b = isinwhere(rect, units, where)

%  ISINWHERE
%
%    B = ISINWHERE(RECT, UNITS, WHERE)
%
%  B is 1 if the rectangle RECT in the units UNITS (either 'normalized' or
%  'pixels') is in the location structure WHERE.  The figure is assumed to be
%  WHERE.FIGURE;
% 
%  For a description of the location structure, see 'help analysis_generic'.

b = 0;
% make sure in same units
if strcmp(where.units,'normalized'),
   if strcmp(units,'pixels'), rect=pixels2normalized(where.figure, rect); end;
elseif strcmp(where.units,'pixels'),
   if strcmp(units,'normalized'),rect=normalized2pixels(where.figure,rect);end;
end;
b=rect(1)>=where.rect(1)&rect(2)>=where.rect(2)&...
	rect(3)<=where.rect(3)&rect(4)<=where.rect(4);
