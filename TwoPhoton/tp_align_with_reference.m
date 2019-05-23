function record = tp_align_with_reference( record )
%TP_ALIGN_WITH_REFERENCE
%
%  RECORD = TP_ALIGN_WITH_REFERENCE( RECORD )
%
% 2011-2014, Alexander Heimel
%

ref_record = tp_get_refrecord( record );
if isempty(ref_record)
    disp('TP_ALIGN_WITH_REFERENCE: No reference.');
    return
end

color_not_matched = [0.7 0.7 0.7];

h.align = figure ('Name','Match ROIs with reference epoch','Position',[328 295 806 425],'NumberTitle','off');

image_height = 0.8;

ti = tpreadconfig(record); % tiffinfo(tpfilename(record));

params = tpprocessparams(record);
channels = params.align_channel;
channels = min(channels,ti.NumberOfChannels);
logmsg(['Aligning on channel ' num2str(channels)]);

image_processing.spatial_filterhandle = params.spatial_filterhandle;
image_processing.spatial_filteroptions = params.spatial_filteroptions;

switch lower(ti.third_axis_name)
    case 't' % XYT
        determine_optimal_zshift = false;
        %  determine_optimal_angle = false;
        brightnesscorrect = true;
        image_processing.unmixing = 0;
        image_processing.spatial_filter = 0;
    otherwise % XYZ
        determine_optimal_zshift = true;
        % determine_optimal_angle = true;
        brightnesscorrect = true; % used to be false
        image_processing.unmixing = 1;
        image_processing.spatial_filter = 1;
end

imgimg = tppreview(record,300,0,[],image_processing);

ref_imgimg = tppreview(ref_record,300,0,[],image_processing);

% subtract modes

img_mode = mode(reshape(imgimg(:,:,1),size(imgimg,1)*size(imgimg,2),1));
if img_mode == 4096-1
    ind = find(imgimg==4095);
    imgimg(ind) = NaN;
    img_mode = mode(reshape(imgimg(:,:,1),size(imgimg,1)*size(imgimg,2),1));
    imgimg(ind) = 4095;
end
imgimg = thresholdlinear(imgimg - img_mode);

ref_img_mode = mode(reshape(ref_imgimg(:,:,1),size(ref_imgimg,1)*size(ref_imgimg,2),1));
if ref_img_mode == 4096-1
    ind = find(ref_imgimg==4095);
    ref_imgimg(ind) = NaN;
    ref_img_mode = mode(reshape(ref_imgimg(:,:,1),size(ref_imgimg,1)*size(ref_imgimg,2),1));
    ref_imgimg(ind) = 4095;
end


ref_imgimg = thresholdlinear(ref_imgimg - ref_img_mode);

if ~isempty(record.ref_transform)
    button = questdlg('Realign image to reference?','Realign','Yes','No','Cancel','No');
    switch button
        case 'Cancel'
            return
        case 'Yes'
            realign = true;
        case 'No'
            realign = false;
    end
else
    realign = true;
end

if ~realign
    angle = [];
    dr = [];
    temp = eval(record.ref_transform);
    assign(temp{:});
    % best_scale = scale;
    best_angle = angle;
    best_dr = dr;
    % best_zshift = zshift;
else
    % match image drift and orientation
    maxcorr = -inf;
    best_scale = 1; % set scale to 1 and ignore for the moment.
    best_angle = nan;
    best_dr = [];
    
    
    disp('TP_ALIGN_WITH_REFERENCE: Determining optimal angle and x-,y-shift');
    for step = 1:3
        switch step
            case 0
                angle_range = 0; % do not turn
            case 1
                angle_range = -8:2:8;
            case 2
                angle_range = best_angle +(-1:1:1);
            case 3
                angle_range = best_angle +(-0.5:0.5:0.5);
        end
        for angle = angle_range
            disp(['TP_ALIGN_WITH_REFERENCE: Trying angle ' num2str(angle) ' degrees...']);
            temp_ref_imgimg = imrotate(ref_imgimg,angle,'nearest','crop');
            searchx = -100:4:100;
            searchy = -100:4:100;
            dr = driftcheck(imgimg(:,:,1),temp_ref_imgimg(:,:,1),searchx, searchy,brightnesscorrect);
            searchx = dr(1)-10:2:dr(1)+10;
            searchy = dr(2)-10:2:dr(2)+10;
            [dr,corr] = driftcheck(imgimg(:,:,1),temp_ref_imgimg(:,:,1),searchx, searchy,brightnesscorrect);
            if corr > maxcorr
                maxcorr = corr;
                best_angle = angle;
                best_dr = dr;
            end
        end
    end
    
    % now align in z-direction
    if determine_optimal_zshift
        disp('TP_ALIGN_WITH_REFERENCE: Determining z-shift (only works for images larger than 300x300)');
        middle_frame = fix(ti.NumberOfFrames/2);
        im = double(tpreadframe(record,channels,middle_frame,image_processing));
        im = imrotate(im,-best_angle,'nearest','crop'); % rotate org image other way
        
        try
            im=im((100:300)+best_dr(2),(100:300)+best_dr(1)); % take inside and shift
            ti_ref = tiffinfo(tpfilename(ref_record));
            best_matching_frame = 1;
            best_correlation = 0;
            for frame = 1:ti_ref.NumberOfFrames
                im_ref = double(tpreadframe(ref_record,channels,frame,image_processing));
                im_ref = im_ref(100:300,100:300);
                correlation = (im_ref(:)'*im(:))/mean(im_ref(:));
                if correlation > best_correlation
                    best_correlation = correlation;
                    best_matching_frame = frame;
                end
            end
            best_zshift = middle_frame - best_matching_frame;
        catch me
            disp(['TP_ALIGN_WITH_REFERENCE: ' me.message]);
            best_zshift = 0;
        end
    else
        best_zshift = 0;
    end
    
    record.ref_transform = ['{''scale'',' num2str(best_scale) ...
        ',''angle'',' num2str(best_angle) ',''dr'',' mat2str(best_dr)  ...
        ',''zshift'',' num2str(best_zshift) ...
        '}'];
end


% show results
if ~isfield(ref_record.ROIs,'celllist')
    ref_record.ROIs.celllist = struct('xi',[],'yi',[],'zi',[]);
    ref_record.ROIs.celllist = ref_record.ROIs.celllist([]);
    ref_record.ROIs.new_cell_index = 1;
end
ref_celllist = ref_record.ROIs.celllist;

% current image
h.cur = subplot('position',[0.51 1-image_height 0.48 image_height]); % current
imgimg = imrotate(imgimg,-best_angle,'nearest','crop');

channel = 1:ti.NumberOfChannels;
mx = [-0.2 0];
mn = [0 0];
gamma = [1 1];

tp_image(imgimg,channel,mx,mn,gamma,tp_channel2rgb(record));
hold on
title(get_title(record));
plot_rois( ref_celllist,[],color_not_matched,-best_dr);

% reference image
h.ref = subplot('position',[0.01 1-image_height 0.48 image_height]);
tp_image(ref_imgimg,channel,mx,mn,gamma,tp_channel2rgb(record));
hold on
plot_rois( ref_celllist,[],color_not_matched);
title(get_title(ref_record));

subplot('position',[0.02 0.02 0.96 1-image_height-0.04]);
axis off;
[y,x] = printtext(['Transform ' record.stack ' from reference to current : ' record.ref_transform]); %#ok<NASGU>


record.ROIs.new_cell_index = ref_record.ROIs.new_cell_index;


function plot_rois( celllist, h, color,shift)
if nargin<2
    h = [];
end
if isempty(h)
    h = gca;
end
if nargin<3
    color = [];
end
if isempty(color)
    color = [0 0 1];
end
if nargin<4
    shift = [ 0 0];
end
for i=1:length(celllist)
    hp = plot(h,celllist(i).xi-shift(1),celllist(i).yi-shift(2),'linewidth',2);
    set(hp,'color',color);
end


function tit=get_title(record)
tit = [record.mouse ' ' record.stack ' ' record.date];