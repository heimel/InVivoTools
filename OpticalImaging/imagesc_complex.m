function img=imagesc_complex( data, colmap,scale,range )
%IMAGESC_COMPLEX produces an hue/brightness image from 2D complex valued array
%
%  IMAGESC_COMPLEX( DATA )
%
%  IMAGESC_COMPLEX( DATA, COLMAP,SCALE,RANGE)
%    Plots DATA is a 2D complex array like using IMAGESC, but the hue
%    is determined by the phase, the brightness by the absolute
%    value of the complex number at each pixel
%
%    COLMAP is colormap. By default the PERIODIC_COLORMAP(100) is used.
%         SCALE='normal','log' 
%                   
%  
%  Sept 2003, Alexander Heimel (heimel@brandeis.edu)

  if nargin<4
    range=[];
  end
  if nargin<3
    scale='normal';% scale='log';
  end
  if nargin<2
    colmap=[];
  end
  
  
  if isempty(scale)
    scale='normal';
  end
  if isempty(colmap)
    colmap=hsv(100);
  end
  
  
  n_colors=size(colmap,1);

  
  angles=round( n_colors* (angle(data)+pi)/(2*pi)  );
  huemap=ind2rgb( angles, colmap );
  
  lengths=abs(data);
  
  if strcmp(scale,'log')==1
    % normalizing log absolute values
    lengths=log(lengths);
    lengths(:)=lengths(:)-mean(lengths(:));
    lengths(:)=lengths(:)/std(lengths(:));
    lengths=0.2*lengths+0.7;
    
    %lengths(:)=lengths(:)-min(lengths(:));
    %lengths(:)=lengths(:)/max(lengths(:));
  elseif isempty(range)
    lengths(:)=lengths(:)-min(lengths(:));
    lengths(:)=lengths(:)/max(lengths(:));
  else
    lengths(find(lengths>range(2)))=range(2);
    lengths(find(lengths<range(1)))=range(1);
    lengths=(lengths-range(1))/(range(2)-range(1));
    
  
  end
  
  % figure; hist(lengths(:),40);
  
  complexmap=huemap;
  complexmap(:,:,1)=huemap(:,:,1).*lengths;
  complexmap(:,:,2)=huemap(:,:,2).*lengths;
  complexmap(:,:,3)=huemap(:,:,3).*lengths;
  complexmap(:)=min(complexmap(:),1);
  complexmap(:)=max(complexmap(:),0);
  imgt=image( complexmap);
  
  if nargout==1
    img=imgt;
  end

    
