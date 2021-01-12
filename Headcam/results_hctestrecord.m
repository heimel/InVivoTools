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

filename = fullfile(record.mouse,'Recording.mpg');
obj = VideoReader(filename);
obj.CurrentTime = measures.starttime;
im_start = readFrame(obj);
im_diff = im_start*0;
im_start = rgb2gray(im_start);
obj.CurrentTime = mean([measures.starttime measures.endtime]);
im_mid = readFrame(obj);
im_mid = rgb2gray(im_mid);
if measures.endtime<=obj.Duration
    obj.CurrentTime = measures.endtime;
else
    obj.CurrentTime = obj.Duration;
    logmsg('Endtime exceeds movie duration');
end
try
    im_end = readFrame(obj);
    im_end = rgb2gray(im_end);
catch me
    logmsg(me.message);
    im_end = 0 * im_mid;
end
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

    
    ylabel('Pupil radius (pxl)');
    xlabel('Time (s)');
    title([record.mouse ' numx ' num2str(record.epoch,'%02d')]);
    xlim([min(measures.frametimes),max(measures.frametimes)]);

    % show blinks
    yl = ylim;
    ind = find(measures.blinks);
    for i=1:length(ind)
       plot( measures.frametimes(ind(i)) *[1 1],yl,'color',[1 1 1]*0.8); 
    end

    plot( measures.frametimes,measures.pupil_rs_smooth,'-k','linewidth',2);

    
    manualtouching = regexp(record.comment,'touching=(\s*\d+)','tokens');
    if ~isempty(manualtouching)
        touching = str2double(manualtouching{1});
       plot( touching *[1 1],yl,'color',[1 1 0]*0.8); 
    end

end

if ~isempty(measures) || isfield(measures,'pupil_noise')
    logmsg(['Pupil noise = ' num2str(measures.pupil_noise)]);
end


logmsg('Measures available in workspace as ''measures'', record as ''global_record''.');
