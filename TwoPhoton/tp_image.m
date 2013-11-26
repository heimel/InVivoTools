function [img,mx,mn,gamma] = tp_image(im,channel,mx,mn,gamma,channel2rgb,fighandle)

global tp_monitor_threshold_level

if nargin<7
    fighandle = [];
end

% interpret default viewing parameters
edge = 10; % avoid edge when determining max and min because of filtering artefacts

if isempty(channel)
    if ndims(im)>2
        channel = [1:size(im,3)];
    else
        channel = 1;
    end
end


if size(im,1)<=(2*edge) || size(im,2)<=(2*edge)
    disp('TP_IMAGE: image size smaller than safety age size used for filtering. Not using edge. Filtered data unreliable');
    edge = 0;
end

if isempty(mx)
    mx=nan(max(channel),1);
end
if isempty(mn)
    mn=nan(max(channel),1);
end
if isempty(gamma)
    gamma=ones(max(channel),1);
end

for ch = channel
    if mx(ch)==0 || isnan(mx(ch))
        if length(channel)==1
            mx(ch) = ceil(max(max(im( (1+edge):(end-edge),(1+edge):(end-edge),ch ))));
        else
            mx(ch) = ceil(max(max(im( (1+edge):(end-edge),(1+edge):(end-edge),ch ))));
        end
    end
    if mx(ch)<0 % i.e. percentile that should be saturated
        vals = im((1+edge):(end-edge),(1+edge):(end-edge),ch);
        mx(ch) = prctile(vals(:),100+mx(ch));
    end
    if  isnan(mn(ch))
        mn(ch) = 0;
    end
    if mn(ch)==-1
        vals = round(im((1+edge):(end-edge),(1+edge):(end-edge),ch));
        mn(ch) = mode(vals(:));
        if mn(ch) == max(vals(:))
            disp(['TP_IMAGE: mode of channel ' num2str(ch) ...
                ' is equal to the maximum. Taking minimum intensity instead of mode.']);
            mn(ch) = min(vals(:));
        end
    end
    if  isnan(gamma(ch))
        gamma(ch) = 1;
    end
end

for ch = channel
    if gamma(ch) == -1 % special for counting puncta on channel 1, should go elsewhere
        vals = thresholdlinear(im((1+edge):(end-edge),(1+edge):(end-edge),ch) - mn(ch));
        vals = vals/(mx(ch)-mn(ch));
        vals(vals>1) = 1;
        mode_v = mode(vals(:));
        gamma(ch) = log(tp_monitor_threshold_level)/log(mode_v);
    end
end


% rescale channel to viewing parameters
% and make rgb image
imrgb = zeros(size(im,1),size(im,2),3);
if length(channel)>1
    for ch = channel
        imrgb(:,:,channel2rgb(ch)) = rescale(im(:,:,ch),[mn(ch) mx(ch)],[0 1]).^gamma(ch);
    end
else
    imrgb(:,:,channel2rgb(ch)) = rescale(im(:,:,ch),[mn(ch) mx(ch)],[0 1]).^gamma(ch);
end

% make image
if ~isempty(fighandle)
    img = image(imrgb,'parent',fighandle);
else
    img = image(imrgb);
end
ax = get(img, 'parent');
axes(ax);
axis equal off
