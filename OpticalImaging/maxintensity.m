function intensity=maxintensity(imgs)
%MAXINTENSITY returns maximum of several images
%
%     INTENSITY=MAXINTENSITY(IMGS)
%
%
  
  intensity=max(imgs,[],3);
  
  % clip infinities
  ind=find(isinf(intensity) & intensity>0);
  intensity(ind)=max(intensity(find(~isinf(intensity))));
  ind=find(isinf(intensity) & intensity<0);
  intensity(ind)=min(intensity(find(~isinf(intensity))));

  
  %img=img(:,:,end);
  return
  
  
  beta=5;
  
  maxs=max(imgs,3);
  
  for stim=1:size(imgs,3)
    imgs(:,:,stim)=imgs(:,:,stim)-maxs;
  end

  
  weights=exp( beta* imgs);
  
  
  sumweights=sum( weights, 3);
  
  img=sum(imgs.*weights,3)./sumweights + maxs;
