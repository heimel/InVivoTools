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
if nargin<4
    colortab_0 = 0;
end

if nargin<6
    maskcoltab_0 = 0;
end
if nargin<7
    maskcoltab_1 = 0;
end

if nargin<9
    cmap = [];
end

if nargin<8
    record = [];
end
if nargin<5
    maskinds = [];
end
if nargin<3
    blank_stim = [];
end
if nargin<2 || isempty(stimlist)
    stimlist = 1:size(data,3);
end

if isempty(cmap)
    cmap = retinotopy_colormap(length(stimlist),1);
end
processparams = oiprocessparams(record);

equalize_area = processparams.wta_equalize_area;
if equalize_area
    max_count = processparams.wta_max_equalizing_steps;
    logmsg('Equalizing area');
else
    max_count = 1;
end

count = 1;
equalizing_factors = ones(length(stimlist),1);
area_condition = zeros(length(stimlist),1);
while count<=max_count % equalizing area
    max_img = data(:,:,stimlist(1));
    for i=stimlist
        maxinds = find( max_img>=data(:,:,i) );
        data__ = data(:,:,i);
        max_img(maxinds) = data__(maxinds);
    end
    max_inds = zeros(size(data(:,:,1)));
    
    for i=stimlist
        ind = find(max_img==data(:,:,i));
        max_inds(ind) = i;
        
        ind = intersect(ind,maskinds);
        area_condition(i) = length(ind);
    end
    if max_count>1
        switch  processparams.wta_equalizing
            case 'max'
                
                [~,ind_area] = max(area_condition);
                equalizing_factors(ind_area) = equalizing_factors(ind_area) * processparams.wta_equalizing_factor;
                data(:,:,ind_area) =  data(:,:,ind_area)*processparams.wta_equalizing_factor;
            case 'min'
                [~,ind_area] = min(area_condition);
                equalizing_factors(ind_area) = equalizing_factors(ind_area) / processparams.wta_equalizing_factor;
                data(:,:,ind_area) =  data(:,:,ind_area)/processparams.wta_equalizing_factor;
        end
    end
    
    if any(equalizing_factors<0.1)
        break
    end
    
    logmsg(['Step' num2str(count) 'Adjusting response of condition ' num2str(ind_area)]);
    count = count+1;
end
logmsg(['Equalizing factors: ' mat2str(equalizing_factors',2)]);



if isempty(blank_stim)
    wtaimg = double(data(:,:,1));
else
    wtaimg = double(data(:,:,blank_stim));
end

wtaimg = wtaimg-min(min(wtaimg));
wtaimg = (maskcoltab_1-maskcoltab_0)*wtaimg/max(max(wtaimg))+maskcoltab_0;
img0 = wtaimg;

for i=stimlist
    wtaimg(max_inds==i) = colortab_0 + i;
end

% to make bloodvessel mask gray
if 0
    wtaimg(find(maskinds)) = img0(find(maskinds));
end

% show with intensity based on maximum
maximg = maxintensity(-data(:,:,1:end));

mask = zeros(size(maximg));
mask(maskinds) = maximg(maskinds);

maximg = clip(maximg,nanmedian(maximg(:)),3*nanstd(maximg(:)));

h = image_intensity(wtaimg',maximg',cmap);

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

% if 1 % no intensity scaling
%     figure;
%     img=image(wtaimg'); axis equal off;
%     colormap(cmap);
% end
