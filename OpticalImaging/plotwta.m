function [h,wtaimg]=plotwta(data,stimlist,blank_stim,colortab_0,maskinds,maskcoltab_0,...
maskcoltab_1,record,cmap)

% PLOTWTA - Plots winner-take-all plot of intrinsic imaging data
%
%   H=PLOTWTA(DATA, STIMLIST, BLANK_STIM, COLORTAB_0, MASKINDS,MASKCOLTAB_0,
%     ...MASKCOLTAB_1,RECORD,CMAP)
%
%  Plots winner-take-all plot of intrinsic imaging data using color map
%  entries COLORTAB_0..COLORTAB_0+length(STIMLIST) for each stimulus and
%  and allowing all points in MASKINDS to 'show through'.  MASKCOLTAB_0 through
%  MASKCOLTAB_1 are used to draw the pixels showing through.  DATA is an
%  XxYxNUMSTIM matrix of imaging data.
%
%  Example: h=plotwta(avg_data,2:8,1,256,0,256);
if nargin<9
    cmap = [];
end

if nargin<8
    record = [];
end

if isempty(cmap)
    cmap = retinotopy_colormap(length(stimlist),1);
end
processparams = oiprocessparams(record);

equalize_area = processparams.wta_equalize_area;
disp(['PLOTWTA: Equalize area is ' num2str(equalize_area)]);
if equalize_area
    max_count = 100;
else
    max_count = 1;
end
   
count = 1; 
while count<=max_count
    max_img = data(:,:,stimlist(1));
    for i=stimlist
        maxinds = find( max_img>=data(:,:,i) );
        data__ = data(:,:,i);
        max_img(maxinds) = data__(maxinds);
    end;
    max_inds = zeros(size(data(:,:,1)));
    
    for i=stimlist
        ind = find(max_img==data(:,:,i));
        max_inds(ind) = i;
        
        ind = intersect(ind,maskinds);
        
        area_condition(i) = length(ind);
    end
    
    [~,max_area] = max(area_condition);
    std(area_condition)
    data(:,:,max_area) =  data(:,:,max_area)*.95; 
    logmsg(['Adjusting response of condition ' num2str(max_area)]);
    count = count+1;
end



if isempty(blank_stim)
  wtaimg = double(data(:,:,1));
else
  wtaimg = double(data(:,:,blank_stim));
end
  
  wtaimg = wtaimg-min(min(wtaimg));
wtaimg = (maskcoltab_1-maskcoltab_0)*wtaimg/max(max(wtaimg))+maskcoltab_0;
img0 = wtaimg;

for i=stimlist
  wtaimg(find(max_inds==i)) = colortab_0 + i;
end;

% to make bloodvessel mask gray
if 0
  wtaimg(find(maskinds)) = img0(find(maskinds));
end
  
%figure;
%img=image(wtaimg'); axis equal off;
%colormap(retinotopy_colors);



% show with intensity based on maximum
maximg=maxintensity(-data(:,:,1:end));

mask=zeros(size(maximg));
mask(maskinds)=maximg(maskinds);

% multiply with light strength for blank stimulus
%maximg=maximg.*(data(:,:,blank_stim)-min(min(data(:,:,blank_stim))));

maximg=clip(maximg,nanmedian(maximg(:)),3*nanstd(maximg(:)));
%maximg(find(maximg==max(maximg(:))))=min(maximg(:));
h=image_intensity(wtaimg',maximg',cmap);


% show with intensity based on difference of maximum and mean
% this is not very good, because it will create boundaries between good
% response zones
if 0   % changed to zero 2006-10-20
  %figure;
  maximg=maxintensity(-data(:,:,2:end));
  meanimg=mean(-data(:,:,2:end),3);
  intensity=maximg-meanimg;
  intensity=clip(intensity);
  image_intensity(wtaimg',intensity',retinotopy_colors);
  axis equal off;
end
