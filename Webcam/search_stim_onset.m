function [brightness, thresholdsStimOnset, peakPoints] = ...
    search_stim_onset(filename, stimStart, arena, frameRate)
%search the roi for the _actual_ stimulus onset
% Azadeh Tafreshiha, feb 2016

%% get the frame and roi
v = VideoReader(filename);
stimFrame = stimStart*frameRate;
start_frame = stimFrame-30-10; %30:length of the stim, 10:for interval
end_frame = stimFrame+90+30;
num_frames  = numel(start_frame:end_frame);%;v.NumberofFrames;

W = 15; H = 30;
Xmin = arena(1)+arena(3)-W;
Ymin = arena(2)+arena(4)/2-H/2;
roiR = [Xmin, Ymin, W, H];
Xmin = arena(1);
roiL = [Xmin, Ymin, W, H];

%% calculate the brightness changes in rois
brightness = zeros(2,num_frames); j = 0; % vector of all averaged brightness (lft and right) values for the ROI
for i = start_frame:end_frame
    j = j+1;
    frame = read(v,i);
    im_roiR = imcrop(frame,roiR);
    im_roiL = imcrop(frame,roiL);
    brightness(1,j)  = mean(im_roiR(:));
    brightness(2,j)  = mean(im_roiL(:));
    %        crossR = min(im_roiR);
    %        crossL = min(im_roiL);
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
stdmin = 3;
stdmax = 20;

threshMinR = low_passR - 6 * sigmaR; % define a threshold value for brightness crossing
threshMaxR = low_passR - 2 * sigmaR; % To avoid getting a mouse.
threshMinL = low_passL - 6 * sigmaL; % define a threshold value for brightness crossing
threshMaxL = low_passL - 2 * sigmaL; % To avoid getting a mouse.
thresholdsStimOnset = [threshMinR; threshMaxR; threshMinL; threshMaxL];

noise_std_detect_ref_r = median(abs(brightness(1,:)))/0.6745;
noise_std_detect_ref_l = median(abs(brightness(2,:)))/0.6745;

thr_ref = stdmin * noise_std_detect_ref_r;        %threshold for detection
thrmax_ref = stdmax * noise_std_detect_ref_l;     %thrmax for artifact removal

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
        indexR(pkdr) = cross_indR(i) + peaksRI(pkdr)-2; %index of the peak within "spike"
        cross_indR0 = indexR(pkdr);
    end
end
for i = 1:length(cross_indL)
    if cross_indL(i) >= cross_indL0 + ref
        pkdl = pkdl + 1; % number of peaks detected + 1
        [peaksL(pkdl), peaksLI(pkdl)] = min(brightness(2,cross_indL(i):cross_indL(i)+ref));
        indexL(pkdl) = cross_indL(i) + peaksLI(pkdl)-2; %index of the peak
        cross_indL0 = indexL(pkdl);
    end
end
pk_frRall = []; pk_frLall = []; peaksRAll = []; peaksLAll = [];

pk_frR = frames(indexR);
pk_frL = frames(indexL);
%     detectR = cross_indR(valid_crossR);

pk_frRall = [pk_frRall, pk_frR];
pk_frLall = [pk_frLall, pk_frL];
peaksRAll = [peaksRAll, peaksR];
peaksLAll = [peaksLAll, peaksL];

peakPoints = [pk_frRall pk_frR peaksR; pk_frLall pk_frL peaksL];
if size(peakPoints) < 4
    peakPoints = [];
end
logmsg('done!')

%%
% % L/R validation of crossings
% min_isi = 1000; % min number of frames between trials
% plot(pk_frRall,peaksRAll,'o'); hold on; plot(pk_frLall,peaksLAll,'o');
%
% pk_frRall2 = [pk_frRall; ones(size(pk_frRall))];
% pk_frLall2 = [pk_frLall; zeros(size(pk_frLall))];
% pks = [pk_frRall2, pk_frLall2];
% if ~isempty(pks)
%     [~, i]=sort(pks(1,:));
% pks_sorted = pks(:,i);
% min_dif = 70;
% max_dif = 120;
% v_inx = diff(pks_sorted(1,:))<max_dif & diff(pks_sorted(1,:))>min_dif;
% v_inx_alt = xor(pks_sorted(2,v_inx), pks_sorted(2,[false, v_inx(1:end-1)])); % return only those that were detected in sequence of left/right
% det_fs = pks_sorted(1,v_inx); % detected frames
% det_fs = det_fs(v_inx_alt); % sequential left/right correction
% figure(3); set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
% for i = 1:numel(det_fs)
%     subplot(ceil(numel(det_fs)/3),3,i);
%     imshow(read(v,det_fs(i)),[]); axis on; title(['Frame: ' num2str(det_fs(i)-2)]);
% end
% figure(3);subplot(m,n,4:6);
% plot([det_fs; det_fs], [repmat(-50,1,length(det_fs)); repmat(130,1,length(det_fs))],'-k');
% end