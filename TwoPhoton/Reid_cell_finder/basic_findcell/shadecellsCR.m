function [shadeimage] = shadecellsCR (image, bwimage,ifnorm,ifplot)
% Makes an RGB image (NxMx3) with the pixels determined by bwimage shaded
% image: input 2-D image   (N x M)
% bwimage:  binary image with same dimensions
% ifnorm: 1 if normalized (default)
% 
% Works by deleting one of the color channels
%
% Clay Reid 9/23/04

image = double(image);

nchandel = 1;  % which channel to delete 1=red

if nargin < 3
    ifnorm=1;
end
if nargin < 4
    ifplot=1;
end
shadeimage = repmat( double(image), [1 1 3]);  % add 3rd color dimension
if ifnorm == 1
    shadeimage = shadeimage/(max(max(image)));
end
shadeimage(:,:,nchandel) = shadeimage(:,:,nchandel) .* (1-bwimage);  % delete channel