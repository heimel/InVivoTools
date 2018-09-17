function [tc_roi,tc_ror,ratio]=get_timecourse(fname,n_images,conditions,...
    roi,ror,compression,show)
%GET_TIMECOURSE reads the timecourse over a subset of pixels
%
%
%  [TC_ROI,TC_ROR,RATIO]=GET_TIMECOURSE(FNAME,N_IMAGES,CONDITIONS,...
%				       ROI,ROR,COMPRESSION,SHOW)
%        calculates the timecourse of file FNAME
%
%
%   2004-2015, Alexander Heimel
%

if nargin<7 || isempty(show)
    show = 1;
end
if nargin<6
    compression = 1;
end
if nargin<5
    ror = [];
end
if nargin<4
    roi = [];
end
if nargin<3
    conditions = [];
end
if nargin<2
    n_images = inf;
end
tc_roi = [];
tc_ror = [];
ratio = [];

% get file info
fileinfo = imagefile_info(fname);
if isempty(fileinfo.name)
    return
end

if fileinfo.n_images<n_images
    n_images = fileinfo.n_images;
end

if isempty(ror) && ~isempty(roi)
    % make ROR complement of ROI
    ror = ones( size(roi))-roi;
end
if isempty(roi)
    % make ROI whole image
    roi = ones( floor(fileinfo.xsize/compression), ...
        floor(fileinfo.ysize/compression) );
end
if isempty(ror)
    % make ROR also whole image
    ror = ones( floor(fileinfo.xsize/compression), ...
        floor(fileinfo.ysize/compression) );
end
pixelind_roi = find(roi'~=0);
pixelind_ror = find(ror'~=0);

% calculate number of batches
memory_max = 64*1024*1024;
n_batches = ceil(fileinfo.filesize/(compression^2)/ ...
    memory_max/fileinfo.n_conditions);

n_frames_per_batch = ceil(n_images/n_batches);

if isempty(conditions)
    conditions = (1:fileinfo.n_conditions);
end

tc_roi = zeros(n_images,length(conditions));
tc_ror = zeros(n_images,length(conditions));

for cond = conditions
    condoffset = (cond-1)*fileinfo.n_images;
    start = 1;
    for i = 1:n_batches
        frames = read_oi_compressed(fname,start+condoffset,...
            n_frames_per_batch,1,compression,0);
        
        if isempty(frames)
            errormsg(['Reading frames from ' fname ]);
            return
        end
        
        n_frames_read = size(frames,3);
        frames = reshape(frames,size(frames,1)*size(frames,2),size(frames,3));
        
        if ~isempty(pixelind_roi)
            avg_roi = mean(frames(pixelind_roi,:),1)';
        else
            avg_roi = mean(frames(:,:),1)';
        end
        
        if ~isempty(pixelind_ror)
            avg_ror = mean(frames(pixelind_ror,:),1)';
        else
            avg_ror = 0*avg_roi+mean(frames(:));
        end
        
        tc_roi(start:start+n_frames_read-1,cond) = avg_roi;
        tc_ror(start:start+n_frames_read-1,cond) = avg_ror;
        start = start+n_frames_read;
    end
end

ratio = tc_roi./tc_ror;

if show==1
    figure
    subplot(3,1,1);
    plot(tc_roi,'.-');
    for i=1:size(tc_roi,2)
        leg(i,:) = ['stim ' char(i+48)]; %#ok<AGROW>
    end
    legend(leg);
    title('ROI');
    
    subplot(3,1,2);
    plot(tc_ror,'.-');
    for i=1:size(tc_ror,2)
        leg(i,:) = ['stim ' char(i+48)];
    end
    legend(leg);
    title('ROR');
    
    subplot(3,1,3);
    plot(ratio,'.-');
    for i=1:size(tc_roi,2)
        leg(i,:) = ['stim ' char(i+48)];
    end
    legend(leg);
    title('ROI/ROR');
end
