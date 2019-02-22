function [celllist,new_roi_index] = import_ref_rois(record)
%IMPORT_REF_ROIS import ROIS for analyzetpstack
%
%  [CELLLIST, NEW_ROI_INDEX] = IMPORT_REF_ROIS(RECORD);
%
% 2011-2017, Alexander Heimel
%

% check if cells can be loaded from reference epoch
ref_record = tp_get_refrecord( record );

if isempty(ref_record) % i.e. no reference record can be produced
    celllist = tp_emptyroirec;
    celllist = celllist([]);
    new_roi_index = 1;
    return
end

if ~isempty(ref_record.ROIs)
    celllist = ref_record.ROIs.celllist;
    celllist = structconvert(celllist,tp_emptyroirec);
    
    % fill in new fields
    empty_roi = tp_emptyroirec;
    for field = fieldnames(empty_roi)'
        if ~isfield(celllist,field{1})
            for i=1:length(celllist)
                celllist(i).(field{1}) = empty_roi.(field{1});
            end
        end
    end
    
    angle  = 0;
    dr = [ 0 0];
    zshift = 0;
    if isempty(record.ref_transform)
        uiwait(warndlg(['Reference transformation information is missing. ' ...
            'Probably you would like to first click on [Align] and [Save], before importing ROIs.'],...
            'Ref trafo missing','modal'));
    else
        temp = eval(record.ref_transform);
        assign( temp{:} ); % assigning dr, angle, scale, zshift
    end
    
     params = tpreadconfig(record);
    
    center_x = params.pixels_per_line/2 + 0.5;
    center_y = params.lines_per_frame/2 + 0.5;
    angle_rad = angle /180 * pi;
    rotmat = [ cos(angle_rad) sin(angle_rad); -sin(angle_rad) cos(angle_rad)];
    if ~exist('scale','var')
        scale = 1;
    end
    
    min_frame = 1; 
    max_frame = params.number_of_frames;
    
    for i = 1:length( ref_record.ROIs.celllist )
        r = [celllist(i).xi(:)' - center_x ;...
            celllist(i).yi(:)' - center_y ];
        r = r * scale;
        r = rotmat*r;
        celllist(i).xi = r(1,:) + center_x;
        celllist(i).yi = r(2,:) + center_y;
        celllist(i).xi = celllist(i).xi+ dr(1);
        celllist(i).yi = celllist(i).yi+ dr(2);
        celllist(i).zi = celllist(i).zi + zshift;
        
        ti = tpreadconfig(record);
        [blankprev_x,blankprev_y] = meshgrid(1:ti.Width,1:ti.Height);
        bw = inpolygon(blankprev_x,blankprev_y,celllist(i).xi,celllist(i).yi);
        celllist(i).pixelinds = find(bw);
        
        if any(celllist(i).zi < min_frame)
            logmsg(['Clipping z-value of ROI ' ...
                num2str(celllist(i).index) ' to minimum frame in this stack.']);
            celllist(i).zi( celllist(i).zi < min_frame ) = min_frame;
        end
        if any(celllist(i).zi > max_frame)
            logmsg(['Clipping z-value of ROI ' ...
                num2str(celllist(i).index) ' to maximum frame in this stack.']);
            celllist(i).zi( celllist(i).zi > max_frame ) = max_frame;
        end
    end
    new_roi_index = ref_record.ROIs.new_cell_index;
else
    ref_record.epoch = record.ref_epoch;
    refscratchfilename = tpscratchfilename( ref_record,[],'stack');
    if exist(refscratchfilename,'file')
        refg = load( refscratchfilename,'-mat');
        if isfield(refg,'celllist') && ~isempty(refg.celllist)
            logmsg('Using cells from reference epoch');
            if isfield(refg,'celllist')
                celllist = refg.celllist;
            end
            if isfield(refg.ROIs,'new_cell_index')
                new_roi_index = refg.ROIs.new_cell_index;
            end
        end
    else
        celllist = tp_emptyroirec;
        celllist = celllist([]);
        new_roi_index = 1;
    end
end
