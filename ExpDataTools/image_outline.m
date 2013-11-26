function img=image_outline( img )
%IMAGE_OUTLINE get edges in of an image
%
%  2008, Alexander Heimel
%
      
img=(abs(spatialfilter(img,1)-img));
