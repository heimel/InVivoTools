function [h,avg,stddev,blocks]=analyse_retinotopy(fname,blocks,early_frames,late_frames,roi,ror,blank_stim,compression,response_sign,record)
%ANALYSE_RETINOTOPY calculates classic retinotopy from imaging data
%
%  [H,AVG,STDDEV,BLOCKS]=ANALYSE_RETINOTOPY(FNAME,DIMENSIONS,BLOCKS,...
%                    EARLY_FRAMES,LATE_FRAMES,ROI,ROR,BLANK_STIM,...
%                    COMPRESSION,RESPONSE_SIGN  )
%
%      FNAME = base filename, e.g. '2004-11-24/mouse_E3'
%      DIMENSIONS = [ # horizontal patches, # vertical patches]
%      BLOCKS = array containing all data blocks to analyse
%      EARLY_FRAMES array containing 'zero-frames', (first frame is 1)
%      LATE_FRAMES array containing frames to analyse, (first frame is 1)
%      ROI = region of interest from DRAG_ROI function
%      BLANK_STIM = number of blank stimulus (first stimulus is 1)
%
%  2004-2013, Alexander Heimel
%

if nargin<10; record = []; end
if nargin<9; response_sign=1; end
if nargin<8; compression=10; end
if nargin<7; blank_stim=[];end
if nargin<6; ror=[]; end
if nargin<5; roi=[]; end
if nargin<4; late_frames=[]; end
if nargin<3; early_frames=[]; end
if nargin<2; blocks=[]; end
if nargin<1;
    disp('Experiment name required, e.g. analyse_retinotopy 2004-11-24/mouse_E3');
    return
end

if early_frames==-1
    ledtest=1;
else
    ledtest=0;
end


if strcmp(record.stim_type,'retinotopy')||...
        strcmp(record.stim_type,'rt_response')||...
        strcmp(record.stim_type,'significance')
    if isnumeric(record.stim_parameters)
        dimensions=record.stim_parameters;
    else
        dimensions=str2num(record.stim_parameters); %#ok<ST2NM>
    end
else
    dimensions=[];
end


bv_mask=[];

base=fname;
filter=[ base 'B*.BLK'];
files=dir(filter);
if isempty(files)
    error(['Could not find any files matching ' filter ]);
end

if isempty(blocks)
    blocks=(0:length(files)-1);
end

experimentlist={};
extension='';
for blk=blocks
    experimentlist{end+1}=[ base 'B' num2str(blk) '.BLK' extension ]; %#ok<AGROW>
    if exist(experimentlist{end},'file')==0
        experimentlist={experimentlist{1:end-1}};
        break
    end
end

fileinfo=imagefile_info(experimentlist{end});
if fileinfo.n_total_images==0
    experimentlist={experimentlist{1:end-1}};
end
if isempty(experimentlist)
    disp('ANALYSE_RETINOTOPY: No blockfiles ready yet.')
    return
end
fileinfo = imagefile_info(experimentlist{1}) %#ok<NOPRT>

if isempty(dimensions)
    dimensions=[1 fileinfo.n_conditions];
end




if isempty(late_frames)
    late_frames=(6:15);
    if isempty(early_frames)
        early_frames=(1:5);
    end
end


if isempty(blank_stim)
    firststim=1;
else
    firststim=2;
end
stimlist=(firststim:fileinfo.n_conditions);

% some checks
if isempty(blank_stim)
    n_stims=length(stimlist);
else
    n_stims=length(stimlist)+1;
end

if fileinfo.n_conditions<n_stims
    errormsg('Too few conditions in data');
    return
end
if fileinfo.n_conditions~=n_stims
    disp(['ANALYSE_RETINOTOPY: Number of conditions in data unequal to specified' ...
        ' list']);
end

if isempty(ror)
    ror=ones(fileinfo.ysize,fileinfo.xsize);
end

if 0 %
    if ~isempty(early_frames)
        disp('Early frames:');
        [early_avg,early_stddev]=average_images(experimentlist,[blank_stim stimlist], ...
            early_frames,'avgframes','none',[], ...
            compression);
    end
end

if ledtest
    [late_avg,late_stddev]=average_images(experimentlist,[blank_stim stimlist], ...
        late_frames,'avgframes','none',1, ...
        compression,ror);
else
    if isempty(early_frames)
        % use frame 1 for subtraction, 2008-06-16
        [late_avg,late_stddev]=average_images(experimentlist,[blank_stim stimlist], ...
            late_frames,'avgframes','subtractframe_ror',1, ...
            compression,ror);
    else
        [late_avg,late_stddev]=average_images(experimentlist,[blank_stim stimlist], ...
            late_frames,'avgframes','subtractframe_ror',early_frames(end), ...
            compression,ror);
    end
end
avg=late_avg;
stddev=late_stddev;

framesize=[size(avg,1) size(avg,2)];
if isempty(roi)  % if no roi, use all pixels
    roi=ones(framesize)';
end
if size(roi,2)~=framesize(1) || size(roi,1)~=framesize(2)
    disp('ANALYSE_RETINOTOPY: ROI size not congruent with image size');
    errordlg('ROI size not congruent with image size','Analyse retinotopy');
    return
end

if 0 % 2006-10-22
    if ~isempty(early_frames) & ~isempty(setxor(early_frames,late_frames)) %#ok<UNRCH>
        % subtracting early images
        avg=late_avg-early_avg;
        avg(:,:,blank_stim)=late_avg(:,:,blank_stim);
    end
end

if 0
    % compute blood vessel and other artifact map based on stddev
    % set pixels with zero stddev to max, because zero std indicates
    % saturation of camera
    %logstd=stddev(:,:,:);
    if ~isempty(early_stddev) %#ok<UNRCH>
        blood_stddev=early_stddev;
    else
        blood_stddev=stddev;
    end
    logstd=sum(blood_stddev,3);
    if ~isempty(early_frames)
        logstd=logstd./sum(early_avg,3);
    end
    maxstd=max(logstd(:));
    logstd(find(logstd==0))=maxstd;
    
    % first clip sttdev
    logstd=log(logstd);
    clipval=mean(logstd(:))+3*std(logstd(:));
    
    % smooth histogram
    [n,x]=hist(logstd(:),1000);
    n=smoothen(n,4);
    
    if 0
        % find first valley after maximum
        [m,i]=max(n);
        valleys=allpeaks(-n);
        valleys=valleys(find(valleys>i));
        valley=x(valleys(1));
        peaks=allpeaks(n);
        peaks=peaks(find(peaks>i));
        peak=x(peaks(1));
        thresh=valley;
        if peak>x(i)
            thresh=peak;
        end
    end
    %thresh=mean(logstd(:))+3*std(logstd(:));
    thresh=prctile(logstd(:),85);
    
    doplot=1;
    [bv_mask] = blood_vessel_mask_std(logstd(:,:,1),thresh,doplot);
end

if 0 % dccorrection
    if ~isempty(ror) %#ok<UNRCH>
        disp('dccorrection using ror and bloodvessel mask');
        avg=dccorrection(avg,ror.*( 1-bv_mask') );
    else
        % no correction
        %   avg=dccorrection(avg,( 1-bv_mask') );
    end
end

spatial_filter = true;
if ~isempty(record)
    switch record.stim_type
        case {'tf','sf'}
            spatial_filter = true;
    end
end

if spatial_filter % spatial filter
    params = oiprocessparams( record );
    
    
    filter=[];
    fp = params.spatial_filter_width;
    if ~isnan(fp)
        disp(['ANALYSE_RETINOTOPY: Filter width set to ' num2str(fp)]);
        filter.width=max(1,fp/fileinfo.xbin/compression);
        filter.unit='pixel';
        avg=spatialfilter(avg,filter.width,filter.unit);
        stddev=spatialfilter(stddev,filter.width,filter.unit)/sqrt(filter.width^2);
    end
end

if ledtest
    onlinemaps(avg,[],dimensions(1),fname,ledtest);
else
    onlinemaps(avg,[],dimensions(1),fname);
end


% normalize if early frames subtracted
if 0
    if ~isempty(setxor(early_frames,late_frames)) %#ok<UNRCH>
        for i=1:size(avg,3)
            %    avg(:,:,i)=avg(:,:,i)-mean(mean(avg(:,:,i)));
            %   avg(:,:,i)=avg(:,:,i)/mean(std(avg(:,:,i)));
            %avg(:,:,i)=avg(:,:,i)/sqrt(sum(sum( avg(:,:,i).*avg(:,:,i))));
        end
    end
end


% plot winner takes all
h=plotwta(response_sign*avg,stimlist,blank_stim,0,bv_mask,5,256,record,...
    retinotopy_colormap(dimensions(1),dimensions(2)));

label=[ ' BLK=' num2str(min(blocks)) ':' ...
    num2str(max(blocks)) ' ' extension ];
title(label);

filename=[base 'wta' extension '.png'];
saveas(gcf,filename ,'png');
disp(['ANALYSE_RETINOTOPY: winner-take-all map saved as: ' filename]);
return

