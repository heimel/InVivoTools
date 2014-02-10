function imgg=rgb2gray(img)
%RGB2GRAY converts rgb image to grayscale
%
% IMG=RGB2GRAY(IMG)
%
%    2003, Alexander Heimel, heimel@brandeis.edu
%
  
img=rgb2hsv(img);
imgg=img(:,:,3);
