function [unmix,frac_ch1_in_ch2 ,frac_ch2_in_ch1] = tp_unmixchannels( im_or_filename, show)
%TP_UNMIXCHANNELS unmixes the fluorescence of the second channel from the first channel
%
%  [UNMIX,FRAC_CH1_IN_CH2,FRAC_CH2_IN_CH1] = TP_UNMIXCHANNELS( IM_OR_FILENAME, SHOW )
%
%  IM_OR_FILENAME is filename or MxNx2 or MxNxPx2 array
%  CURRENTLY SETS FRAC2_CH1_IN_CH2 = 0
%
%
% Unmixing of second channel from the first, assuming maximal mixing
% C1 = G + aR
% C2 = R + bG
%   => C1 = G + a( C2-bG) = (1-ab)G + aC2
%   => G = (C1-aC2)/(1-ab)
%    now use that G must be positive for all its entries
%    if ab<1, then we need C1-aC2>0
%    => C1/C2 > a, i.e. a = min(C1/C2)
%       and b = min(C2/C1) using the vice versa argument
%    if ab>1, then we need C1-aC2<0
%    => C1/C2 < a, i.e. a = max(C1/C2)
% all under the no noise assumption
%
% in practice when there is noise, the line of maximum ratio of channel C2
% over C1 is taken
%
% 2011-2012, Alexander Heimel
%

if nargin<2
    show = [];
end
if isempty(show)
    show = false;
end

if ischar(im_or_filename)
    im = imread( im_or_filename);
else
    im = im_or_filename;
    im_or_filename = [];
end

n_channels = size(im,ndims(im));
if n_channels ~= 2
    logmsg('Channel unmixing is only implemented for 2 channels');
    unmix = im;
    frac_ch1_in_ch2 = 0;
    frac_ch2_in_ch1 = 0;
    return;
end

store_gcf = gcf;

if show
hbar = waitbar(0,'Unmixing channels');
end

% remove saturated pixels, because correct ratio will be lpst
logmsg('Only using unsaturated pixels');
sat = 2^12 -1 ; % should be editable, now assuming 12 bit images
imsmooth = double(im);
imsmooth( imsmooth(:)>=sat) = NaN;
% smooth image with gaussian filter to reduce noise
imsmooth = tp_spatial_filter( double(imsmooth), 'smoothen','1');

% crop edges to avoid filtering artefacts
sim = size(im);
edge = 5;
if min(sim(1:end-1))<=(2*edge)
    logmsg('Image size smaller than safety age size used for filtering. Not using edge. Filtered data unreliable');
    edge = 0;
end

if ndims(im)>3 % i.e stack
    imsmooth = imsmooth(1+edge:end-edge, 1+edge:end-edge, 1+edge:end-edge, :);
else % single image
    imsmooth = imsmooth(1+edge:end-edge, 1+edge:end-edge, :);
end

if ndims(im)>3 % i.e stack
    imvals = reshape( imsmooth, (size(im,1)-2*edge) * (size(im,2)-2*edge) * (size(im,3)-2*edge), n_channels) ;
else % single image
    imvals = reshape( imsmooth, (size(im,1)-2*edge) * (size(im,2)-2*edge) , n_channels)  ;
end
clear('imsmooth');

if show
waitbar(0.1,hbar);
end

imvals = double(imvals);

% to save memory, only use 10000 elements
compression = ceil(numel(imvals)/2/10000);

% deduct mode, assuming mode is real black value, works well for stacks
%    and single optical slices, perhaps less well for maximum projections
%    and certainly less well for z-averages
black = zeros(1,n_channels);
for ch = 1:n_channels
    black(ch) = mode(round(imvals(1:compression:end,ch)));
    logmsg(['Mode channel ' num2str(ch) ' is ' num2str(black(ch))]);
end

logmsg('Removing modes from channels. only using still positive pixels');
% negative pixels after removing mode are assumed to be background (as will be still positive pixels)  
for ch = 1:n_channels
    imvals(:,ch) = imvals(:,ch) - black(ch);
    imvals( imvals(:,ch)<=0, ch) = NaN;
end

imvals = reshape(imvals(:,:),size(im,1)-2*edge,size(im,2)-2*edge,size(im,3)-2*edge,n_channels);

if show
waitbar(0.3,hbar);
end

params = tpprocessparams;

switch params.unmixing_use_pixels % see tppprocessparams for history
    case 'mean'
        imvals = nanmean(imvals,3);
        vals1 = flatten(imvals(:,:,1));
        vals2 = flatten(imvals(:,:,2));
        clear('imvals');
    case 'all'
        if ndims(imvals)==4
            vals1 = reshape(imvals(:,:,:,1),[numel(imvals)/2 1]);
            vals2 = reshape(imvals(:,:,:,2),[numel(imvals)/2 1]);
        else
            vals1 = reshape(imvals(:,:,1),[numel(imvals)/2 1]);
            vals2 = reshape(imvals(:,:,2),[numel(imvals)/2 1]);
        end
        clear('imvals');
    case 'topchan2'
        if ndims(imvals)==4
            vals1 = reshape(imvals(:,:,:,1),[numel(imvals)/2 1]);
            vals2 = reshape(imvals(:,:,:,2),[numel(imvals)/2 1]);
        else
            vals1 = reshape(imvals(:,:,1),[numel(imvals)/2 1]);
            vals2 = reshape(imvals(:,:,2),[numel(imvals)/2 1]);
        end
        clear('imvals');
        median_channel2 = prctile( vals2,99 );
        ind = (vals2>median_channel2);
        vals1 = vals1(ind);
        vals2 = vals2(ind);
    case 'highchan2' % current favorite, and used for the Neuron paper
        % uses higher values (after coarse outlier removal)
        if ndims(imvals)==4
            vals1 = reshape(imvals(:,:,:,1),[numel(imvals)/2 1]);
            vals2 = reshape(imvals(:,:,:,2),[numel(imvals)/2 1]);
        else
            vals1 = reshape(imvals(:,:,1),[numel(imvals)/2 1]);
            vals2 = reshape(imvals(:,:,2),[numel(imvals)/2 1]);
        end
        clear('imvals');
        % remove high outliers
        thres = nanmean( vals2 ) + 3*nanstd(vals2);
        ind = (vals2<thres);
        % select higher left over values 
        % i.e. assuming the lower intensities constitute mostly noise
        thres = nanmean( vals2(ind) ) + 2*nanstd(vals2(ind));
        ind = (vals2>thres);
        vals1 = vals1(ind);
        vals2 = vals2(ind);
end
vals = vals1./ vals2;
ind = ( ~isnan(vals(:)) & ~isinf(vals(:)) );
vals = vals(ind);
vals1 = vals1(ind);
vals2 = vals2(ind);

switch params.which_frac_ch2_in_ch1
    case 'prctile1'
        logmsg('Taking percentile 1 as minimum ratio');
        frac_ch2_in_ch1 = prctile(vals,1);
    case 'prctile5'
        logmsg('Taking percentile 5 as minimum ratio');
        frac_ch2_in_ch1 =prctile(vals,5);
    case 'mode' % runs into problems with autofluorescence of debris, e.g. 10.24.1.28,tuft4-mono,day24
        vals = vals(vals>0);
        [n,x] = hist(log(vals),100);
        [~,ind_max]=max(n);
        frac_ch2_in_ch1 = exp(x(ind_max));
    case 'firstmax' % used for Neuron paper
        % uses first peak in ratio
        th = cart2pol(vals2/max(vals2),vals1/max(vals1));
        [y,x] = slidingwindowfunc(th,vals2,0,pi/2/100,pi/2,2*pi/2/100,'top10',1);
        y = smoothen(y,0.5);
        [~,indp] = findpeaks(y,'minpeakheight',0.3*max(y),'MINPEAKDISTANCE',2);
        [v2,v1] = pol2cart( x(indp(1)),y(indp(1))) ;
        frac_ch2_in_ch1 = v1*max(vals1)/(v2*max(vals2));
end

if show
waitbar(0.5,hbar);
end

logmsg(['Fraction of Ch2 in Ch1: ' num2str(frac_ch2_in_ch1,2)]);

% no unmixing of channel 2
frac_ch1_in_ch2 = 0;

unmix = zeros(size(im),'double');

if show
waitbar(0.7,hbar);
end

if ndims(im)<4
    im_nomode(:,:,1) = thresholdlinear( im(:,:,1) - black(1));
    im_nomode(:,:,2) = thresholdlinear( im(:,:,2) - black(2));
    
    % note: unmix can take negative values!
    unmix(:,:,1) = ( (double(im(:,:,1)) - frac_ch2_in_ch1*double(im_nomode(:,:,2)))/(1-frac_ch1_in_ch2 * frac_ch2_in_ch1) ) ;
    unmix(:,:,2) = ( (double(im(:,:,2)) - frac_ch1_in_ch2*double(im_nomode(:,:,1)))/(1-frac_ch1_in_ch2 * frac_ch2_in_ch1) ) ;
    
    % shift smallest value to zero to make positive. assume acquisition once done at less then 16 bits.
    unmix(:,:,1) = unmix(:,:,1) - min(min(unmix(:,:,1)));
    unmix(:,:,2) = unmix(:,:,2) - min(min(unmix(:,:,2)));
else
    im_nomode(:,:,:,1) = thresholdlinear( im(:,:,:,1) - black(1) ); % can be done without thresholdlinear, using im is uint16
    im_nomode(:,:,:,2) = thresholdlinear( im(:,:,:,2) - black(2) );
    
    % note: unmix can take negative values!
    unmix(:,:,:,1) = ( (double(im(:,:,:,1)) - frac_ch2_in_ch1*double(im_nomode(:,:,:,2)))/(1-frac_ch1_in_ch2 * frac_ch2_in_ch1) );
    unmix(:,:,:,2) = ( (double(im(:,:,:,2)) - frac_ch1_in_ch2*double(im_nomode(:,:,:,1)))/(1-frac_ch1_in_ch2 * frac_ch2_in_ch1) );
    
    % shift smallest value to zero to make positive. assume acquisition once done at less then 16 bits.
    unmix(:,:,:,1) = unmix(:,:,:,1) - min(min(min(unmix(:,:,:,1))));
    unmix(:,:,:,2) = unmix(:,:,:,2) - min(min(min(unmix(:,:,:,2))));
    
    unmix = uint16( unmix );
end

if show
close(hbar);
end

if show
    figure('name','Unmixing results','NumberTitle','off');
    
    subplot(2,3,1);
    hold on;
    plot(vals1,vals2,'.','color',0.7*[1 1 1]);
    xlabel('Channel 1');
    ylabel('Channel 2');
    colormap default
    cm = colormap;
    % make color circle
    ncl=30;
    yl = ylim;
    ylim([0 yl(2)]);
    xl = xlim;
    xlim([0 xl(2)]);
    radius = 0.2;
    for i=0:ncl;
        plot( radius*xl(2)*sin(i/ncl/2*pi),...
            radius*yl(2)*cos(i/ncl/2*pi),...
            'ok','color',cm(round(1+i/ncl*63),:),...
            'markerfacecolor',cm(round(1+i/ncl*63),:));
    end
    plot(frac_ch2_in_ch1*[min(vals2) max(vals2)], [min(vals2) max(vals2)],'y-');
    
    th = cart2pol(vals2/yl(2),vals1/xl(2));
    [vals2_smooth,th_smooth] = slidingwindowfunc(th,vals2,0,pi/2/100,pi/2,2*pi/2/100,'top10',1);
    vals2_smooth = smoothen(vals2_smooth,0.5);
    [y,x] = pol2cart(th_smooth,vals2_smooth./cos(th_smooth));
    plot(x/yl(2)*xl(2),y,'-k','linewidth',2);
    
    subplot(2,3,2)
    [~,ind_max]=max(im(:,:,:,2),[],3);
    imratio = zeros(size(im,1),size(im,2));
    for i=1:size(imratio,1)
        for j=1:size(imratio,2)
            imratio(i,j) = atan(double(im_nomode(i,j,ind_max(i,j),1))/double(im_nomode(i,j,ind_max(i,j),2)));
        end
    end
    
    imagesc(imratio);
    axis image;axis off
    title('Ratio Ch1/Ch2 (max)');
    
    subplot(2,3,3);
    if ndims(im)==4
        imagesc(max(im(:,:,:,2),[],3));
    else
        imagesc(im(:,:,2));
    end
    axis image;
    axis off
    title('Original channel 2 (max)');
    
    subplot(2,3,4);
    if ndims(im)==4
        imagesc(max(im(:,:,:,1),[],3));
    else
        imagesc(im(:,:,1));
    end
    axis image;
    axis off
    title('Original channel 1 (max)');
    
    
    subplot(2,3,5);
    if ndims(im)==4
        imagesc(max(unmix(:,:,:,1),[],3));
    else
        imagesc(unmix(:,:,1));
    end
    axis image;
    axis off
    title('Unmixed channel 1 (max)');
    
    subplot(2,3,6);
    if ndims(im)==4
        imagesc(min(unmix(:,:,:,1),[],3));
        set(gca,'clim',[0 max(flatten(unmix(:,:,:,1)))])
    else
        imagesc(unmix(:,:,1));
    end
    axis image;
    axis off
    title('Unmixed channel 1 (min)');
    
    colormap default
end

if ischar(im_or_filename) % then store result
    [pathstr,name,ext] = fileparts(im_or_filename);
    unmix_filename = fullfile(pathstr,[name '_unmixed' ext]);
    imwrite(unmix,unmix_filename,'tif')
end

figure(store_gcf);

% additional explanation
% The goal of the procedure is to remove the fluorescence of the red
% fluorescent protein from  the green channel. In our case, channel 1 is
% green, channel 2 is red.
%
% The key idea is that the this red fluorescence is present in the green
% channel in a constant -but unknown- ratio. The pixels without any true
% green fluorescence would only have the 'leaky' red fraction. These pixels
% would have the maximum Channel 2/Channel 1 ratio and this ratio would be
% the fraction of Channel 2 that would always be present in Channel 1.
%
% This simple idea does not work directly because of noise. Most of
% tp_unmixchannels reducing the effect of noise on this estimate.
%
% First, it is important to not apply any median filtering on the raw stack
% before starting this procedure.
%
% Line 62: saturated pixels are removed from the analysis by making the NaN
% (not a number)
%
% Line 64: stack is blurred with a gaussian filter as a first step to
% reduce the impact of noise
%
% Line 75: edges are removed, to stay away from filtering artefact
% introduced by blurring
%
% Line 98: true black level is found by assuming it is the mode. For this
% it is important that the fluorescence is relatively sparse. This works
% well in a stack, not so well in a z-projected image, and not at all well
% in an z-averaged image. Also it is important that any possible dark-noise
% reduction or imaging offset is not too aggressive and that the mode is
% not 0. Check this in the image histogram. A mode of zero mostly like
% means that the real dark level was below zero, and can thus no longer be
% estimated.
%
% Line 106: Modes are removed, and negative pixels are set to NaN and thus
% taken out of the analysis.
%
% Line 144: Values with a very low channel 2 intensity will probably give a
% very noise estimate of the channel 2/channel 1 ratio. After removal after
% the very high valued outliers, only values more than 2 standard
% deviations above the mean of channel 2 intensity are considered
%
% Line 182: Of all the ratios, a sliding average in polar coordinates is
% taken, and the peak with the highest Ch2/Ch1 ratio is considered as the
% true fraction of Ch2 that is always present in Ch.
%
% The remainder of the function produces some plots to check the validity
% of the functions. Especially of interest, are the images of the maximum
% and minimum z-projection of channel 1 after removal. If too little is
% removed of the dendritic red signal, the dendrites are still very visible
% in the maximum projection. If too much is removed, the dendrites will
% become very visible in the minimum projection.
%






