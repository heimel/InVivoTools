function [phase_img,phase_img_raw]=plotwta2mask(data,stimlist,blank_stim,colortab_0,colortab_1,mask1inds,mask2inds,mask1col, mask2col)

% PLOTWTA2MASK-Plots winner-take-all plot of intrinsic imaging data with 2 masks
%
%   PHASE_IMG=PLOTWTA2MASK(DATA, STIMLIST, BLANK_STIM, COLORTAB_0,MASK1INDS,...
%		MASK2INDS,MASK1COL,MASK2COL)
%
%  Plots winner-take-all plot of intrinsic imaging data using color map
%  entries COLORTAB_0..COLORTAB_1 for each stimulus and
%  and allowing all points in MASK#INDS to 'show through'. MASK#COLTAB_0 through
%  MASK#COLTAB_1 are used to draw the pixels showing through.  DATA is an
%  XxYxNUMSTIM matrix of imaging data.
%
%  Example: PHASE_IMG=PLOTWTA2MASK(avg_data,2:8,1,256,256+100,0,0,0,256,0,256);

phase_img = zeros(size(data(:,:,stimlist(1))));

for i=1:length(stimlist),
	phase_img = phase_img+double(data(:,:,stimlist(i)))*exp(sqrt(-1)*2*pi*(i-1)/length(stimlist));
end;

phase_img_raw = phase_img;

phase_img = colortab_0 + (colortab_1-colortab_0)*(angle(phase_img)+pi)/(2*pi);

phase_img(find(mask1inds)) = mask1col;
phase_img(find(mask2inds)) = mask2col;
image(phase_img'); axis equal off;


disp(['Max pixel ' num2str(max(max(phase_img)) ) '.']);
disp(['Min pixel ' num2str(min(min(phase_img)) ) '.']);
