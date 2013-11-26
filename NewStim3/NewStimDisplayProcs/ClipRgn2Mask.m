function tex = ClipRgn2Texture(window, clipShape, clipRgn, bgc)

% CLIPRGN2TEXTURE - Convert a PTB-2 clipping region to a PTB-3 texture
%
%  TEX = CLIPRGN2TEXTURE(WINDOW,CLIPSHAPE,CLIPRGN, [BGCOLOR])
%
%  Creates a texture mask for a clipping region that is defined according to the old
%  PTB-2 (Psychophysics Toolbox verion 2) routine Screen('SetDrawingRegion');
%
%  If clipShape == 1, then clipRgn should be a set of 1x4 points that define a rectangle
%  If clipShape == 2, then clipRgn should be a set of 1x4 points that define an oval
%                      (a rectangle should be provided, but the region is an oval)
%  If clipShape == 3, then clipRgn should be a polygon (see Screen('FillPoly?') for
%                      instructions of how to prepare a polygon)
%
%  The mask region is filled with BGCOLOR. If this is not specified,
%  BGCOLOR is [128 128 128].
%
%  Be sure to close the texture TEX with Screen('Close',TEX) when you are finished
%  using it so it won't sit around in memory.
%  

if nargin<3, bgcolor = [128 128 128];  else, bgcolor = bgc; end;
rect = Screen('Rect',window);
bg = repmat(0,rect(4)-rect(2)+1,rect(3)-rect(1)+1);

clipRgn,

switch clipShape,
	case 0,
		% do nothing
	case 1,
		mask=bg;
		mask(clipRgn(2):clipRgn(4),clipRgn(1):clipRgn(3)) = 255;
		%Screen('FillRect',tex,255,clipRgn);
	case 2,
		mask=bg;
		[X,Y]=meshgrid(rect(1):rect(3),rect(2):rect(4));
		x0 = mean(clipRgn([1 3]));
		y0 = mean(clipRgn([2 4]));
		a = diff(clipRgn([1 3]))/2;
		b = diff(clipRgn([2 4]))/2;
		mask = 255 * uint8(  ((X-x0).^2)/(a.^2)+((Y-y0).^2)/(b^2) <=1);
		%Screen('FillOval',tex,255,clipRgn);
	case 3,
		mask = 255*poly2mask(clipRgn(:,1),clipRgn(:,2),rect(4)-rect(2)+1,rect(3)-rect(1)+1);
		%Screen('FillPoly',tex,255,clipRgn); % why doesn't this work?  it doesn't though
end;

 % now convert this to alpha channel

global mypoints myimg
mypoints = clipRgn;
myimg = cat(3,bg+bgcolor(1),bg+bgcolor(2),bg+bgcolor(3),mask);

tex = Screen('MakeTexture',window,cat(3,bg+bgcolor(1),bg+bgcolor(2),bg+bgcolor(3),255-mask));
