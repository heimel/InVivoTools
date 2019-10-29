function [h,wtaimg] = plotwta(data,stimlist,blank_stim,colortab_0,maskinds,maskcoltab_0,...
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
%
% 200X-2019 Alexander Heimel

if nargin<8
    record = [];
end
if nargin<7 || isempty(maskcoltab_1)
    maskcoltab_1 = 0;
end
if nargin<6 || isempty(maskcoltab_0)
    maskcoltab_0 = 0;
end
if nargin<5
    maskinds = [];
end
if nargin<4 || isempty(colortab_0)
    colortab_0 = 0;
end
if nargin<3
    blank_stim = [];
end
if nargin<2 || isempty(stimlist)
    stimlist = 1:size(data,3);
end
if nargin<9 || isempty(cmap)
    cmap = retinotopy_colormap(length(stimlist),1);
end
params = oiprocessparams(record);

if params.wta_equalize_area
    max_count = params.wta_max_equalizing_steps;
    logmsg('Equalizing area');
else
    max_count = 1;
end

if params.wta_normalize_each_condition
    data = double(data);
    for c = 1:size(data,3)
        data(:,:,c) = data(:,:,c) - min(min(data(:,:,c)));
        data(:,:,c) = data(:,:,c) ./ max(max(data(:,:,c)));
    end
end

orgdata = data; % for original intensity scaling

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
        switch  params.wta_equalizing
            case 'max'
                [~,ind_area] = max(area_condition);
                equalizing_factors(ind_area) = equalizing_factors(ind_area) * params.wta_equalizing_factor;
                data(:,:,ind_area) =  data(:,:,ind_area)*params.wta_equalizing_factor;
            case 'min'
                [~,ind_area] = min(area_condition);
                equalizing_factors(ind_area) = equalizing_factors(ind_area) / params.wta_equalizing_factor;
                data(:,:,ind_area) =  data(:,:,ind_area)/params.wta_equalizing_factor;
        end
    end
    
    if any(equalizing_factors<0.1)
        break
    end
    count = count+1;
end
if params.wta_equalize_area
    logmsg(['Equalizing steps: ' num2str(count)]);
    logmsg(['Equalizing factors: ' mat2str(equalizing_factors',2)]);
end

if isempty(blank_stim)
    wtaimg = double(data(:,:,1));
else
    wtaimg = double(data(:,:,blank_stim));
end

wtaimg = wtaimg-min(min(wtaimg));
wtaimg = (maskcoltab_1-maskcoltab_0)*wtaimg/max(max(wtaimg))+maskcoltab_0;

for i = stimlist
    wtaimg(max_inds==i) = colortab_0 + i;
end

% show with intensity based on maximum
maximg = maxintensity(-orgdata(:,:,1:end));

% clip
if ~isempty(params.wta_clipping) && params.wta_clipping>0
    maximg = clip(maximg,nanmedian(maximg(:)),3*nanstd(maximg(:)));
end

h = image_intensity(wtaimg',maximg',cmap,params.wta_range);


