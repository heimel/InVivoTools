function [newimage,mask]= NewStimMasker(theImage, rect, regioncode, clipRect, clip_value)

% NewStimMasker - Sets pixels outside of a drawing region to a clip value
%
%  
%  [NEWIMAGE,MASK] = NEWSTIMMASKER(IMAGE,RECT,REGIONCODE,REGIONPARAM,...
%	OUTSIDE_VALUE)
%
%  This function sets all pixels in the image IMAGE that are outside of a
%  designated "drawing region" to be the value specified in OUTSIDE_VALUE.
%  The resulting image is returned in NEWIMAGE, and the location of the applied
%  mask is returned in MASK (255 equals masked, 0 equals pass through).
%  RECT is the location where IMAGE will be drawn on the screen.
%
%  REGIONCODE can be:
%
%     0:  no masking region; the original image is returned as-is
%     1:  a rectangle; REGIONPARAM should be a 1x4 rectangle indicating
%            [LEFT TOP RIGHT BOTTOM]
%     2:  an oval; REGIONPARAM should specify a rectangular outline of the
%            oval  [LEFT TOP RIGHT BOTTOM]
%     3:  a polygon: REGIONPARAM should specify the vertices of the polygon
%            in [x1 y1; x2 y2; ... xn yn]
%
%     Note that REGIONPARAM should be in "global" screen coordinates, for
%     backwords compatibility with PBTv2 'SetDrawingRegion'.
%    

newimage = theImage;

switch regioncode,
	case 0,
		mask = zeros(size(theImage));
	case {1,2,3},
		width = diff(rect([1 3])); height = diff(rect([2 4]));
		widthvec = linspace(rect(1),rect(3),size(theImage,2));
		heightvec = linspace(rect(4),rect(2),size(theImage,1));
		%mskimgcmplx = repmat(1:size(theImage,2),size(theImage,1),1)+sqrt(-1)*repmat([1:size(theImage,1)]',1,size(theImage,2));
                mskimgcmplx = repmat(widthvec,length(heightvec),1)+sqrt(-1)*repmat(heightvec',1,length(widthvec));
                if regioncode==1,
			poly = [clipRect(1) clipRect(2); clipRect(3) clipRect(2); clipRect(3) clipRect(4); clipRect(1) clipRect(4)];
                elseif regioncode==2,
                        ctr = [mean(clipRect([1 3])) mean(clipRect([2 4]))];
			clipwidth = diff(clipRect([1 3])); clipheight = diff(clipRect([2 4]));
                        polyclipRect=(([clipRect([1 2]);clipRect([3 2]);clipRect([3 4]);clipRect([1 4])]-repmat(ctr,4,1))')'+repmat(ctr,4,1);
                        xx=linspace(-clipwidth/2,clipwidth/2,200);
                        yyp=(clipheight/clipwidth) * sqrt(clipwidth*clipwidth/4-xx.*xx); yyn=-yyp(end:-1:1);
                        poly=(([xx' yyp' ; xx(end:-1:1)' yyn']')'+repmat(ctr,200*2,1));
			%figure % for debugging
			%plot(poly(:,1),poly(:,2),'b--');
                elseif regioncode==3,
                        poly = clipRect;
                end;
                polyinds = insideorborder(mskimgcmplx(:),poly(:,1)+sqrt(-1)*poly(:,2),0.1);
                mask= 255*ones(size(mskimgcmplx));
                mask(polyinds) = 0;
                newimage(find(mask)) = clip_value;
		newimage = reshape(newimage,size(theImage,1),size(theImage,2));
	case 4, % already a mask, nothing to do
		mask = clipRect;
end;
