function [mask] = blood_vessel_mask_std(img_std,thresh,doplot)
% BLOOD_VESSEL_MASK - Returns a mask of blood vessels in an Image by STD
%
%  [MASK]=BLOOD_VESSEL_MASK_STD(IMG_STD,THRESH,PLOT)
%
% Returns a mask of the blood vessels in an optical brain image by examining
% the standard deviation.  Blood vessel pixels appear to have much higher
% variability across conditions than the stimulus-related deviations (a
% heuristic method).
%
% IMG_STD is an XxY matrix containing the standard deviation of each pixel.
% THRESH is a threshold above which to mark pixels as belonging to the blood
% vessels.  If PLOT is 1, the mask is plotted along with the original image and
% a histogram of the standard deviation values (useful for choosing the
% threshold).
%
% If THRESH has two elements, then only points between the two thresholds
% are included.

if length(thresh)==1,
	mask = (img_std >= thresh);
else, mask = ((img_std<=min(thresh))|(img_std>=max(thresh)));
end;

if doplot,
	h = figure;
	[n,x]=hist(reshape(img_std,1,prod(size(img_std))),...
		round(prod(size(img_std))/250));
	subplot(3,1,1); imagesc(img_std');colormap(gray);colorbar;
	c = caxis;
	title('Standard deviation Image');ylabel('pixels');xlabel('pixels');

	subplot(3,1,2); bar(x,n);hold on;a=axis;
	if length(thresh)==1, plot([thresh thresh],[a(3) a(4)],'b');
	else, plot([min(thresh) min(thresh)],[a(3) a(4)],'b');
	      plot([max(thresh) max(thresh)],[a(3) a(4)],'b');
	end;
	title('Histogram of standard deviation with threshold in blue');
	ylabel('Number of points'); xlabel('Standard deviation of intensity');

	subplot(3,1,3);
	newimg = repmat(min(min(img_std)),size(img_std,1),size(img_std,2));
	newimg(find(mask)) = max(max(img_std));
	imagesc(newimg');colormap(gray);caxis(c);colorbar;
	title('Mask points');ylabel('pixels');xlabel('pixels');
end;
