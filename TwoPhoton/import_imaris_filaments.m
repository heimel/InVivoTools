function [celllist,new_cell_index] = import_imaris_filaments( record, new_cell_index )
%IMPORT_IMARIS_FILAMENTS imports imagej rois
%
%  [CELLLIST, NEW_CELL_INDEX] = IMPORT_IMARIS_FILAMENTS( RECORD, NEW_CELL_INDEX )
%
% 2011, Alexander Heimel
%

disp('IMPORT_IMARIS_FILAMENTS: pixelinds still to fill in');

if nargin<2
    new_cell_index = 1;
end

temp =  tpfilename(record);
[temppath,tempfile] = fileparts( temp );
tppath = fullfile(temppath,tempfile);

roifiles = dir(fullfile(tppath,'dendrite_*.mat'));
if isempty(roifiles)
    disp(['IMPORT_IMARIS_FILAMANENTS: no dendrite files present in ' tppath ]);
    celllist = [];
    return
end

% read image resolution to convert imaris measurements from um to pixels
inf = tpreadconfig(record );
switch inf.x_unit
    case 'um'
        x_step = inf.x_step;        
    otherwise
        error('IMPORT_IMARIS_FILAMENTS: unknown x unit');
end
switch inf.y_unit
    case 'um'
        y_step = inf.y_step;        
    otherwise
        error('IMPORT_IMARIS_FILAMENTS: unknown x unit');
end
switch inf.z_unit
    case 'um'
        z_step = inf.z_step;        
    otherwise
        error('IMPORT_IMARIS_FILAMENTS: unknown x unit');
end

for d=1:length(roifiles)
    roi = load(fullfile(tppath, roifiles(d).name),'-mat');
    roirec = tp_emptyroirec;
    roirec.dirname = '.';% roifiles(d).name;
    roirec.pixelinds = []; 
    roirec.xi = double(roi.vPos(:,1)) / x_step;
    roirec.yi = double(roi.vPos(:,2)) / y_step;
    roirec.zi = double(roi.vPos(:,3)) / z_step;
    roirec.index = new_cell_index;
    new_cell_index = new_cell_index + 1;
    roirec.type = 'dendrite';
    roirec.labels = roifiles(d).name(1:findstr(roifiles(d).name,'.mat')-1); %  'GFP';
    roirec.dimensions = 1;
    celllist(d) = roirec;
end
disp(['IMPORT_IMARIS_FILAMENTS: imported ' num2str(length(celllist)) ' rois']);