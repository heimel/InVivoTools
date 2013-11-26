function record = tp_match_rois_with_reference( record, match_unique, match_linked)
%TP_MATCH_ROIS_WITH_REFERENCE
%
% 2011, Alexander Heimel
%

if nargin<3
    match_linked = [];
end
if isempty(match_linked)
    match_linked = 0;
end
if nargin<2
    match_unique = [];
end
if isempty(match_unique)
    match_unique = 1;
end

ref_record = tp_get_refrecord( record );
if isempty(ref_record)
    disp('No reference.');
    return
end
  
    
color_not_matched = [0.7 0.7 0.7];
color_new = [0.7 0.7 0.7 ];
color_persistent = [0 0 0.7];

image_processing.unmixing = 1;
image_processing.spatial_filter = 1;

h.match = figure ('Name','Match ROIs with reference epoch',...
    'Position',[328 295 1024 425],'NumberTitle','off',...
    'toolbar','none','menubar','none');

image_height = 0.9;

subplot('position',[0.02 0.02 0.96 1-image_height-0.04]);
axis off;
[y,x] = printtext('Click on matching location in left panel'); %#ok<NASGU>
%[y,x] = printtext('No match? No existing puncta? Right click in left panel.',y);
%[y,x] = printtext('No match? Existing puncta? Left click in left panel to create new.',y);



h.cur = subplot('position',[0.51 1-image_height-0.02 0.48 image_height]); % current


imgimg = tppreview(record,300,0,[1 2],image_processing);
tp_image(imgimg,[1 2],[-0.2 0],[-1 -1],[1 1],tp_channel2rgb(record))
hold on

h.cur_xl = xlabel('Current');
set(h.cur_xl,'visible','on');

title(get_title(record));
if isfield(record.ROIs,'celllist')
    plot_rois( record.ROIs.celllist,[],color_not_matched);
end


h.ref = subplot('position',[0.01 1-image_height-0.02 0.48 image_height]); 
ref_imgimg = tppreview(ref_record,300,0,[1 2],image_processing);
if isempty(record.ref_transform)
    record = tp_align_with_reference( record );
end
scale = 1; 
angle = 0; 
dr = [0 0];
if isempty(record.ref_transform)
   disp('Need to align with reference. Proceeding with zoom off');
   zoom_in = false;
else

    temp = eval(record.ref_transform);
    assign(temp{:});
    best_scale = scale;
    best_angle = angle;
    best_dr = dr;
    zoom_in = true;
end

    
% load celllist and new_cell_index from reference stack
%ref_scratchfilename = tpscratchfilename(ref_record,[],'stack');
%if ~exist(ref_scratchfilename,'file')
%    disp('TP_MATCH_ROIS_WITH_REFERENCE: No ROIs for reference stack');
%    return
%end
%ref_g = load(ref_scratchfilename);
if ~isfield(ref_record.ROIs,'celllist')
    ref_record.ROIs.celllist = struct('xi',[],'yi',[],'zi',[]);
    ref_record.ROIs.celllist = ref_record.ROIs.celllist([]);
    ref_record.ROIs.new_cell_index = 1;
end
    
ref_celllist = ref_record.ROIs.celllist;
record.ROIs.new_cell_index = ref_record.ROIs.new_cell_index;

% show reference image
mm = mode(reshape(ref_imgimg(:,:,1),size(ref_imgimg,1)*size(ref_imgimg,2),1)); % take mode before rotating
ref_imgimg = imrotate(ref_imgimg,best_angle,'nearest','crop');
tp_image(ref_imgimg,[1 2],[-0.2 0],[mm -1],[1 1],tp_channel2rgb(record))

h.ref_xl = xlabel('Reference');
set(h.ref_xl,'visible','on');

hold on
title(get_title(ref_record));
width = size(ref_imgimg,2);
height = size(ref_imgimg,1);

% rotate reference rois
angle_rad = best_angle/180*pi;
for i=1:length(ref_celllist)
    r = transpose([ref_celllist(i).xi(:) ref_celllist(i).yi(:)]);
    r(1,:) = r(1,:) - width/2;
    r(2,:) = r(2,:) - height/2;
    r = [cos(angle_rad) sin(angle_rad); -sin(angle_rad) cos(angle_rad)]*r;
    r(1,:) = r(1,:) + width/2;
    r(2,:) = r(2,:) + height/2;
    ref_celllist(i).xi = r(1,:);
    ref_celllist(i).yi = r(2,:);
end

% plot reference rois
plot_rois( ref_celllist,[],color_not_matched);


if ~isfield(record.ROIs,'celllist') || isempty(record.ROIs.celllist)
    disp('no ROIs present in current stack');
end

t = 0:1/8192:0.1; %i.e. 100 ms sampled at 8192 Hz
sound_non_match =  sin(t*440*2*pi).*sin(t/0.1*2*pi)/2;
sound_match =  sound_non_match(1:2:end);


if match_unique
    % go over each ROI and mark persistent if it has a counterpart in
    % reference
    for i = 1:length(record.ROIs.celllist)
        ind = find( [ref_celllist(:).index] == record.ROIs.celllist(i).index,1);
        if ~isempty(ind)
            % i.e. index is not unique
            ref_cell = ref_celllist( ind);
            plot_rois( record.ROIs.celllist(i),h.cur,color_persistent);
            plot_rois( ref_cell,h.ref,color_persistent);
        end
    end %i
end

% now go over each ROI and match ROIs
record.ROIs.celllist = sort_db(record.ROIs.celllist,{'neurite'});


% temp function to solve problem with missing distance in neurite field
disp('TP_MATCH_ROIS_WITH_REFERENCE: temporary fix for missing distance');
ln = cellfun(@length,{record.ROIs.celllist.neurite});
for i=find(ln==1)
    record.ROIs.celllist(i).neurite(2) = NaN;
end

neuritestab = reshape([record.ROIs.celllist(:).neurite],2,length(record.ROIs.celllist(:)))';
neurites = uniq(neuritestab(:,1));
neurites = neurites(~isnan(neurites));

for i = 1:length(neurites)
    % find neurite and sort along longest axis
    ind_neurite = find([record.ROIs.celllist(:).index]==neurites(i));
    ind = (neuritestab(:,1)==neurites(i));
    if range(record.ROIs.celllist(ind_neurite).xi) > range(record.ROIs.celllist(ind_neurite).yi)
        record.ROIs.celllist(ind) = sort_db(record.ROIs.celllist(ind),{'xi'});
    else
        record.ROIs.celllist(ind) = sort_db(record.ROIs.celllist(ind),{'yi'});
    end
end

for i = 1:length(record.ROIs.celllist)
    if match_unique && any( [ref_celllist(:).index] == record.ROIs.celllist(i).index)
        % i.e. index is not unique
        continue
    end

    if  is_linearroi(record.ROIs.celllist(i).type)
        % do not match dendrites
        continue
    end
    
    if match_linked && isnan(record.ROIs.celllist(i).neurite(1))
        % ROI not linked to neurite, thus not match, but assign new index
        record.ROIs.celllist(i).index = record.ROIs.new_cell_index;
        record.ROIs.new_cell_index = record.ROIs.new_cell_index + 1;
        plot_rois( record.ROIs.celllist(i),h.cur,color_new);
        continue
    end
    
    disp(['Matching current ROI index: ' num2str(record.ROIs.celllist(i).index)] );
    set(h.cur_xl,'string',['Current: ' num2str(record.ROIs.celllist(i).index)]);
    
    if zoom_in
        % zoom to ROI
        zoom_pixels = 50;
        %     current
        cur_roi_center = [mean( record.ROIs.celllist(i).xi) mean( record.ROIs.celllist(i).yi)];
        axis(h.cur,[cur_roi_center(1)+[-zoom_pixels zoom_pixels] ...
            cur_roi_center(2)+[-zoom_pixels zoom_pixels]]);
        %     ref
        axis(h.ref,[cur_roi_center(1)+[-zoom_pixels zoom_pixels]-best_dr(1) ...
            cur_roi_center(2)+[-zoom_pixels zoom_pixels]-best_dr(2)]);
    end
    
    % highlight current ROI
    plot_rois( record.ROIs.celllist(i),h.cur,[1 1 0]);

    % get click on matching ref ROI
    axes(h.ref);
    x = [];
    while isempty(x)
        [x,y] = ginput(1);
    end
    found_match = false;
    for j=1:length(ref_celllist)
        if inpolygon(x,y,[ref_celllist(j).xi ref_celllist(j).xi(1)],...
                [ref_celllist(j).yi ref_celllist(j).yi(1)]) && strcmp(ref_celllist(j).type,'dendrite')==0
            record.ROIs.celllist(i).index = ref_celllist(j).index;
            found_match = true;
            break
        end
    end
    if found_match
        % match, i.e. persistent punctum
        sound(sound_match);
        plot_rois( record.ROIs.celllist(i),h.cur,color_persistent);
        plot_rois( ref_celllist(j),h.ref,color_persistent);
        if strcmp(record.ROIs.celllist(i).type,ref_celllist(j).type)==0
            disp(['Punctum types do not match. Ref type = ' ...
                ref_celllist(j).type ' Current type = ' ...
                record.ROIs.celllist(i).type]);
        end
        record.ROIs.celllist(i).index = ref_celllist(j).index;
    else
        % no match, i.e. new punctum
        sound(sound_non_match);
        plot_rois( record.ROIs.celllist(i),h.cur,color_new);
        record.ROIs.celllist(i).index = record.ROIs.new_cell_index;
        record.ROIs.new_cell_index = record.ROIs.new_cell_index + 1;
    end
    
    disp(['Index became: ' num2str(record.ROIs.celllist(i).index)] );
end

% close figure
close(h.match);


function plot_rois( celllist, h, color,shift)
if nargin<2
    h = [];
end
if isempty(h)
    h = gca;
end
axes(h);
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
    hp = plot(celllist(i).xi-shift(1),celllist(i).yi-shift(2),'linewidth',2);
    set(hp,'color',color);
end

function tit=get_title(record)
tit = [record.mouse ' ' record.stack ' ' record.date];