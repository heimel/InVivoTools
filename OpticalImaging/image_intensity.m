function h=image_intensity(img,intensity,colmap)
%IMAGE_INTENSITY
%
%  IMAGE_INTENSITY(IMG,INTENSITY,COLMAP)
%
%  2004, Alexander Heimel
%
  
 if nargin<3
    colmap=hsv(5);
  end
  n_colors=size(colmap,1);

%  img=img-min(img(:));
%  img=img./max(img(:));
%  img=ceil(img*(n_colors-1));
  
  huemap=ind2rgb( img, colmap );
  

  ind=find(isinf(intensity) & intensity>0);
  intensity(ind)=max(intensity(find(~isinf(intensity))));
  ind=find(isinf(intensity) & intensity<0);
  intensity(ind)=min(intensity(find(~isinf(intensity))));
  intensity=intensity-min(intensity(:));
  intensity=intensity./max(intensity(:));
  
  
  if 0
  % normalizing log absolute values
  intensity=log(intensity);
  intensity(:)=intensity(:)-mean(intensity(:));
  intensity(:)=intensity(:)/std(intensity(:));
  intensity=0.2*intensity+0.7;
  % figure; hist(intensity(:),40);
  end
  
  %imagesc(intensity);colormap(gray);
  %axis equal off;
  
  h=figure;
  complexmap=huemap;
  complexmap(:,:,1)=huemap(:,:,1).*intensity;
  complexmap(:,:,2)=huemap(:,:,2).*intensity;
  complexmap(:,:,3)=huemap(:,:,3).*intensity;
  complexmap(:)=min(complexmap(:),1);
  complexmap(:)=max(complexmap(:),0);
  image( complexmap);
  axis equal off;
