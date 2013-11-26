function img=plotwta2mask(data,stimlist,blank_stim,colortab_0,mask1inds,mask2inds,mask1col, mask2col)

% PLOTWTA2MASK-Plots winner-take-all plot of intrinsic imaging data with 2 masks
%
%   H=PLOTWTA2MASK(DATA, STIMLIST, BLANK_STIM, COLORTAB_0,MASK1INDS,...
%		MASK2INDS,MASK1COL,MASK2COL)
%
%  Plots winner-take-all plot of intrinsic imaging data using color map
%  entries COLORTAB_0..COLORTAB_0+length(STIMLIST) for each stimulus and
%  and allowing all points in MASK#INDS to 'show through'. MASK#COLTAB_0 through
%  MASK#COLTAB_1 are used to draw the pixels showing through.  DATA is an
%  XxYxNUMSTIM matrix of imaging data.
%
%  Example: h=plotwta(avg_data,2:8,1,256,0,0,0,256,0,256);

max_img = data(:,:,stimlist(1));
for i=2:length(stimlist),
	maxinds = find( max_img>=data(:,:,stimlist(i)) );
	data__ = data(:,:,stimlist(i));
	max_img(maxinds) = data__(maxinds);
end;
max_inds = zeros(size(data(:,:,1)));

for i=1:length(stimlist),
	max_inds(find(max_img==data(:,:,stimlist(i)))) = i;
end;

wtaimg = double(data(:,:,1));

for i=1:length(stimlist),
	wtaimg(find(max_inds==i)) = colortab_0 + i;
end;

wtaimg(find(mask1inds)) = mask1col;
wtaimg(find(mask2inds)) = mask2col;
img=image(wtaimg'); axis equal off;
