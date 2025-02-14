function n = grect2local(r,units,lrect,fig)

%  R = GRECT2LOCAL(RECT, UNITS, LRECT [, FIGURERECT])
%
%    Takes a rectangle RECT, which is normalized to be in [(0,0), ... (1,1)],
%  and computes new values returned in R so RECT is normalized within LRECT,
%  which is itself also a rect normalized to be in [(0,0), ... (1,1)].  
%  LRECT is not [x0 y0 width height] but rather is [x0 y0 x1 y1].  UNITS
%  determines the units of the new rectangle, either 'normalized' or 
%  'pixels'.  In the case of 'pixels', a figure rectangle must be given to
%  determine the mapping between 'normalized' and 'pixels'.

w=lrect(3)-lrect(1); h=lrect(4)-lrect(2);

n = [lrect(1)+w*r(1) lrect(2)+h*r(2) r(3)*w r(4)*h];

if strcmp(units,'pixels'),
   n=normalized2pixels(fig,n);
end;
