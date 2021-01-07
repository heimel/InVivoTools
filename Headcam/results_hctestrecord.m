function results_hctestrecord( record)
%RESULTS_HCTESTRECORD display results from head camera record
%
%  RESULTS_HCTESTRECORD( RECORD)
%
% 2021, Alexander Heimel

global measures global_record
global_record = record;
evalin('base','global measures');
evalin('base','global analysed_script');
evalin('base','global global_record');

measures = record.measures;

if isempty(measures)
    logmsg('No measures. Run analysis first');
    return
end

% show start, mid, and end
filename = 'Recording.mpg';
obj = VideoReader(filename);
obj.CurrentTime = measures.starttime;
im_start = readFrame(obj);
im_diff = im_start*0;
im_start = rgb2gray(im_start);
obj.CurrentTime = mean([measures.starttime measures.endtime]);
im_mid = readFrame(obj);
im_mid = rgb2gray(im_mid);
obj.CurrentTime = measures.endtime;
im_end = readFrame(obj);
im_end = rgb2gray(im_end);
figure('Name',[record.mouse ' ' num2str(record.epoch) ' Overlay'],'NumberTitle','off');
im_diff(:,:,1) = im_start;
im_diff(:,:,2) = im_mid;
im_diff(:,:,3) = im_end;
image(im_diff)
hold on
axis off image
text(5,1,'Red = start, Green = middle, Blue = end','VerticalAlignment','top','color',[1 1 1]);
title([filename ' numx' num2str(record.epoch,'%02d')])
disp('Check if the led reflection spot is white');



if isfield(measures,'frametimes') && ~isempty(measures.frametimes) && ~all(isnan(measures.frametimes))
    figure('Name',[record.mouse ' ' num2str(record.epoch) ' Radius '],'NumberTitle','off');
    hold on
    plot( measures.frametimes,measures.pupil_rs,'.r');
    plot( measures.frametimes,measures.pupil_rs_smooth,'-k','linewidth',2);
    ylabel('Pupil radius (pxl)');
    xlabel('Time (s)');
    title([record.mouse ' numx ' num2str(record.epoch,'%02d')]);
    xlim([min(measures.frametimes),max(measures.frametimes)]);
end

measures.starttime
measures.frametimes(1)

logmsg('Measures available in workspace as ''measures'', record as ''global_record''.');
