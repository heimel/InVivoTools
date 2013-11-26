function [celllist, new_cell_index] = import_imagej_rois( record, new_cell_index )
%IMPORT_IMAGEJ_ROIS imports imagej rois
%
%   [CELLLIST, NEW_CELL_INDEX] = IMPORT_IMAGEJ_ROIS( RECORD, NEW_CELL_INDEX )
%
% 2011, Alexander Heimel
%

disp('IMPORT_IMAGEJ_ROIS: pixelinds still to fill in');

temp =  tpfilename(record);
[temppath,tempfile,tempext] = fileparts( temp );
tppath = fullfile(temppath,tempfile);

roifiles = dir(fullfile(tppath,'*.roi'));
if isempty(roifiles)
    % perhaps zipped?
    zipfiles = dir(fullfile(tppath,'*.zip'));
    for i=1:length(zipfiles)
        unzip( fullfile( tppath, zipfiles(i).name ),tppath);
    end
    roifiles = dir(fullfile(tppath,'*.roi'));
    if isempty(roifiles)
        disp(['IMPORT_IMAGEJ_ROIS: no roi files present in ' tppath ]);
        celllist = [];
        return
    end
end
    
for d=1:length(roifiles)
    roi = imagej_roiread(fullfile(tppath, roifiles(d).name) );
    roirec = tp_emptyroirec;

    roirec.dirname = '.';% roifiles(d).name;
    roirec.pixelinds = []; 
    roirec.xi = roi(:,1);
    roirec.yi = roi(:,2);
    roirec.zi = [];
    roirec.index = new_cell_index;
    new_cell_index = new_cell_index + 1;
    switch roifiles(d).name(end)
        case 'd'
            roirec.type = 'shaft';
        case 's'
            roirec.type = 'spine';
        otherwise 
            roirec.type = 'unknown';
    end
    roirec.labels = 'GFP';

    celllist(d) = roirec;
end
disp(['IMPORT_IMAGEJ_ROIS: imported ' num2str(length(celllist)) ' rois']);