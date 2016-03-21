function img=spatialfilter(img,width,unit)
%SPATIALFILTER convolve images with gaussian kernel  
%  
%  IMG=SPATIALFILTER(IMG,WIDTH,UNIT)
%
%      WIDTH Gaussian sigma in micron
%      UNIT  'pixel', 'micron' 
%
%  2004, Alexander
  
if nargin<3
  unit='pixel';
end
if nargin<2
  width=3; 
end

pixelsize=5; % in micron

if strcmpi(unit,'micron')==1
  sigma=width/pixelsize;
else
  sigma=width;
end

for stim=1:size(img,3)
  img(:,:,stim)=smoothen(img(:,:,stim),sigma);
end
