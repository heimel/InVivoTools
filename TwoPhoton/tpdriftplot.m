function tpdriftplot(record,channel)
%TPDRIFTPLOT shows drift correction plot
%
%  TPDRIFTPLOT(RECORD, CHANNEL)
%
% 2017, Alexander Heimel

if nargin<2 || isempty(channel)
    channel = 1;
end

driftfilename = tpscratchfilename( record, [], 'drift');
if ~exist(driftfilename,'file')
    logmsg(['No driftfile ' driftfilename ' exists.']);
    return
end

params = tpreadconfig(record);

intervals = [ params.frame_timestamp(1) params.frame_timestamp(2)];
first_image = tpreaddata(record,intervals, {(1:params.lines_per_frame * params.pixels_per_line)}, 3, channel);
first_image = reshape( first_image{1}, params.lines_per_frame, params.pixels_per_line);

intervals = [ params.frame_timestamp(end-1) inf];
last_image = tpreaddata( record,intervals, {(1:numel(first_image))}, 3, channel);
if isempty(last_image{1})
    logmsg('Lost last image');
end
last_image=reshape(last_image{1},size(first_image,1),size(first_image,2));

dr = load(driftfilename,'-mat');

figure;
subplot(2,2,1);
im0 = first_image;
im0 = rescale(im0,[prctile(im0(:),1) prctile(im0(:),99)],[0 1]);
imagesc(im0);
colormap(gray(256));
axis image
title('First image');

subplot(2,2,2);
im1 = last_image;
im1 = rescale(im1,[prctile(im1(:),1) prctile(im1(:),99)],[0 1]);
im2 =  zeros([size(im0) 3]);

im2(:,:,2) = im1; % green
im2(:,:,1) = im0;  % red
image(im2);
axis image
title('red = first, green = last image');

subplot(2,2,3);
plot(dr.drift.x);
title('X drift'); ylabel('Pixels'); xlabel('Frame #');
subplot(2,2,4);
plot(dr.drift.y);
title('Y drift'); ylabel('Pixels'); xlabel('Frame #');
