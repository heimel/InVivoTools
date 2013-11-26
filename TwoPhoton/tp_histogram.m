function tp_histogram(record,opt)
%TP_HISTOGRAM
%
% 2011, Alexander Heimel
%

inf=tpreadconfig(record);

for channel = 1:inf.NumberOfChannels
    im(:,:,:,channel) = tpreadframe(record,channel,1:inf.NumberOfFrames,opt);
end

if inf.NumberOfChannels>1
    channel2rgb = tp_channel2rgb(record);
else
    channel2rgb = 0;
end

figure('Name','Histogram','NumberTitle','off');
n_rows = 2;
n_cols = 1+inf.NumberOfChannels;

for channel = 1:inf.NumberOfChannels
    subplot(n_rows,n_cols,1);
    hold on
    vals = double(im(:,:,:,channel));
    vals = vals(:);
    mode_im{channel} = mode(vals);
    [n,x] = hist(vals,100);
    % n = n /numel(vals);
    h1 = plot(x,n);
    
    subplot(n_rows,n_cols,n_cols+1);
    hold on
    vals = vals(vals<500);
    n = histc(vals,-0.5:1:300.5);
    h2 = plot(0:301,n);
    
    switch channel2rgb(channel)
        case 0
            clr = [0 0 0];
        case {1,2,3}
            clr  = [0 0 0 ];
            clr(channel2rgb(channel)) = 1;
    end
    set(h1,'color',clr);
    set(h2,'color',clr);
    
    
end

subplot(n_rows,n_cols,1);
xlim([0 2^12]); % for 12-bit
yl = ylim;
ylim([1 yl(2)]);
set(gca,'yscale','log');
xlabel('Intensity');
ylabel('Number of pixels');
title([record.mouse ' ' record.stack ' ' record.date]);


for ch = 1:inf.NumberOfChannels
    subplot(n_rows,n_cols,n_cols+1+ch);
    imrgb = zeros(size(im,1)*size(im,2),3);
    rgb = channel2rgb(ch);
    
    vals = double(max(im(:,:,:,ch),[],3));
    vals = vals(:);
    imrgb(:,rgb) = vals;
    
    % below mode make inverted color
    %    imrgb(vals<=prctile(vals(:),70),:) = 4095;
    %    imrgb(vals<=prctile(vals(:),70),rgb) = 0;
    imrgb(vals<=mode(vals),:) = 4095;
    imrgb(vals<=mode(vals),rgb) = 0;
    %imrgb(vals<=median(vals(:)),:) = 4095;
    %  imrgb(vals<=median(vals(:)),rgb) = 0;
    %
    % make saturated white
    imrgb(vals>=4095,:) = 4095; % make white
    
    imrgb = imrgb / 4096;%max(imrgb(:));
    
    %mim = mim - mode_im{ch};
    %mim(mim<0) = 0;
    imrgb = reshape(imrgb,size(im,1),size(im,2),3);
    image(imrgb);
    axis image off;
end

