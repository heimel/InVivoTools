function [pk_frR,pk_frL] = search_stim_onset(filename, stimStart)
v = VideoReader(filename);
frameRate = get(v, 'FrameRate');
stimFrame = stimStart*frameRate;
start_frame = stimFrame-30-10; %30:length of the stim, 10:for interval
end_frame = stimFrame+90+30;
num_frames  = numel(start_frame:end_frame);%;v.NumberofFrames;
fontSize = 14;
frame1 = read(v,stimFrame); % read a frame at the beginning. I chose 5550 for now
figure(3);
imshow(frame1, []); % just show it
axis on;
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
message1 = sprintf('Select the chamber arena region.');
message2 = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
% message1=msgbox('Select the chamber arena region.');
% set(message1, 'Position', [100 100 100 100])
uiwait(msgbox(message1));
% roiR = getrect; % this is a classical methid. which is also ok but the one bellow is better
h = imrect; % select a ROI in the frame
binaryImage = h.createMask();
arena = getPosition(h);
W = 15; H = 30;
Xmin = arena(1)+arena(3)-W;
Ymin = arena(2)+arena(4)/2-H/2;
roiR = [Xmin, Ymin, W, H];
Xmin = arena(1);
roiL = [Xmin, Ymin, W, H];

m = 2; n = 3;
h2 = imrect(gca, roiR);
h3 = imrect(gca, roiL);
binaryImage2 = h2.createMask();
binaryImage3 = h3.createMask();

subplot(m,n,1);
imshow(frame1,[]); axis on; title('Sample Frame');
subplot(m,n,2);
burned_frame = frame1;
burned_frame(binaryImage) = 0;
imshow(burned_frame,[]); axis on; title('Selection of arena');

subplot(m,n,3);
burned_frame = frame1;
burned_frame(binaryImage2 | binaryImage3) = 255;
imshow(burned_frame,[]); axis on; title('ROI');
    
    brightness = zeros(2,num_frames); j = 0; % vector of all averaged brightness (lft and right) values for the ROI
    for i = start_frame:end_frame
        j = j+1;
        frame = read(v,i);
        im_roiR = imcrop(frame,roiR);
        im_roiL = imcrop(frame,roiL);
        brightness(1,j)  = mean(im_roiR(:));
        brightness(2,j)  = mean(im_roiL(:));
       crossR = min(im_roiR);
       crossL = min(im_roiL);
    end
    len = length(brightness);
    frames = start_frame:end_frame;
    % threshMinR = mean(brightness(1,:)) - 5 * sigmaR; % define a threshold value for brightness crossing
    % threshMaxR = mean(brightness(1,:)) - 2 * sigmaR; % To avoid getting a mouse.
    % threshMinL = mean(brightness(2,:)) - 5 * sigmaL; % define a threshold value for brightness crossing
    % threshMaxL = mean(brightness(2,:)) - 2 * sigmaL; % To avoid getting a mouse.
    % for more sophisticated thresholding try low pass filtering
    % make the filter first. filters the input data using a rational transfer
    % function defined by the numerator and denominator coefficients b and a, respectively.
    windowSize = 50; % size of the moving average filter
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    
    edgeCorrFactor = filter(b,a,ones(1,length(brightness)));
    low_passR = filter(b,a,brightness(1,:))./edgeCorrFactor; % low pass filter
    low_passL = filter(b,a,brightness(2,:))./edgeCorrFactor; % low pass filter
    sigmaR = std(brightness(1,:));
    sigmaL = std(brightness(2,:));
    
    
    threshMinR = low_passR - 6 * sigmaR; % define a threshold value for brightness crossing
    threshMaxR = low_passR - 2 * sigmaR; % To avoid getting a mouse.
    threshMinL = low_passL - 6 * sigmaL; % define a threshold value for brightness crossing
    threshMaxL = low_passL - 2 * sigmaL; % To avoid getting a mouse.
    
    % search the frames
    crossingsR = (brightness(1,:) > threshMinR & brightness(1,:) < threshMaxR);
    crossingsL = (brightness(2,:) > threshMinL & brightness(2,:) < threshMaxL);
    cross_indR = find(crossingsR>0); % find indices of brightness values with threshold crossings
    cross_indL = find(crossingsL>0); % find indices of brightness values with threshold crossings
    ref = 10; % refractory period in frame units
    cross_indR0 = 0; pkdr = 0; indexR = []; peaksR = []; peaksRI=[];
    cross_indL0 = 0; pkdl = 0; indexL = []; peaksL = []; peaksLI=[];

    for i = 1:length(cross_indR)
        if cross_indR(i) >= cross_indR0 + ref
            pkdr = pkdr + 1; % number of peaks detected + 1
            [peaksR(pkdr), peaksRI(pkdr)] = min(brightness(1,cross_indR(i):cross_indR(i)+ref));
            indexR(pkdr) = cross_indR(i) + peaksRI(pkdr)-3; %index of the peak
            cross_indR0 = indexR(pkdr);
       
        end
     
    end
    for i = 1:length(cross_indL)
         if cross_indL(i) >= cross_indL0 + ref
            pkdl = pkdl + 1; % number of peaks detected + 1
            [peaksL(pkdl), peaksLI(pkdl)] = min(brightness(2,cross_indL(i)));
            indexL(pkdl) = cross_indL(i) + peaksLI(pkdl)-3; %index of the peak
            cross_indL0 = indexL(pkdl);
         
        end
    end
    
    valid_crossR = diff(cross_indR)<2; % find the first of the crossings ina series
    valid_crossL = diff(cross_indL)<2; % find the first of the crossings ina series
    detectR = cross_indR(valid_crossR);
    figure(3);
    subplot(m,n,4:6);
    plot(frames,brightness(1,:),'color',[0 2/3 1]); hold on;
    plot(frames,brightness(2,:),'color',[1 2/3 0]); hold on;
    plot(frames,threshMinR,'--','color',[0 1/3 1]); 
    plot(frames,threshMaxR,'--','color',[0 1/3 1]);
    plot(frames,threshMinL,'--','color',[1 1/3 0]);
    plot(frames,threshMaxL,'--','color',[1 1/3 0]);
    
    pk_frR = frames(indexR);
    pk_frL = frames(indexL);
    plot(pk_frR,peaksR,'k^','markerfacecolor','k'); axis tight;
    plot(pk_frL,peaksL,'k^','markerfacecolor','m'); axis tight;
    
