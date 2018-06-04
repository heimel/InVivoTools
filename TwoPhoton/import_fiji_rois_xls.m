function [celllist, new_cell_index] = import_fiji_rois_xls( filename, record, new_cell_index )
%IMPORT_FIJI_ROIS_XLS imports fiji rois xls
%
%   [CELLLIST, NEW_CELL_INDEX] = IMPORT_FIJI_ROIS_XLS( FILENAME, RECORD, NEW_CELL_INDEX )
%
% 2018, Alexander Heimel
%

processparams = tpprocessparams(record);

[xlsnum,xlstxt] = xlsread(filename);

labels = xlstxt(1,:);

indexcol = strcmp(labels,'Index');
xcol = strcmp(labels,'X');
ycol = strcmp(labels,'Y');

zcol = strcmp(labels,'Position');
if ~any(zcol)
    zcol = strcmp(labels,'Pos');
elseif ~any(zcol)
    zcol = strcmp(labels,'Z');
elseif ~any(zcol)
    errormsg('Cannot find Z-column in excel file');
end
    

wcol = strcmp(labels,'Width');
hcol = strcmp(labels,'Height');

n_rois = size(xlsnum,1);


ud = get(gcf,'Userdata');
sz = size(get(ud.previewim,'CData'));
[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));

empty_roi = tp_emptyroirec(record);


for i=1:n_rois
    roi = empty_roi;
    
    roi.index = xlsnum(i,indexcol);
    roi.dirname = '.';
    
    x = xlsnum(i,xcol);
    y = xlsnum(i,ycol);
    z = xlsnum(i,zcol);
    
    if any(hcol)
        ar = xlsnum(i,hcol)/xlsnum(i,wcol);
        radx = round(xlsnum(i,wcol)/2);
        rady = round(xlsnum(i,hcol)/2);
    else
        ar = 1;
        radx = round(xlsnum(i,wcol)/2);
        rady = radx;
    end
    if radx == 0
        radx = processparams.default_roi_disk_radius_pxl;
        rady = radx;
    end
    
    dr = [0 0]; % no drift
    
    xi_ = ((-radx):1:(radx));
    yi_p = sqrt(rady^2- ar^2*xi_.^2);
    yi_m = - sqrt(rady^2-ar^2*xi_.^2);
    
    roi.xi = [xi_ xi_(end:-1:1)]+x+dr(1);
    roi.yi = [yi_p yi_m(end:-1:1)]+y+dr(2);
    roi.zi = ones(size(roi.xi))*z;
    
    bw = inpolygon(blankprev_x,blankprev_y,roi.xi,roi.yi);
    roi.pixelinds = find(bw);
    celllist(i) = roi; %#ok<AGROW>
end

new_cell_index = max([celllist(:).index])+1;

logmsg(['Imported ' num2str(length(celllist)) ' rois']);