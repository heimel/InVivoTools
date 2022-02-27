function  [cell_detected_all,radii] = load_ilastik_results( img_name,img_info,padding_width,verbose)
%LOAD_ILASTIK_RESULTS to load elastic hd5 file in AMaSiNe
%
% Used in loading results in AMaSiNe
%
% 2021, Alexander Heimel

if nargin<4 || isempty(verbose)
    verbose = false;
end

cell_detected_all = [] ;

[~,filename,~] = fileparts(img_name);
hd5name = [filename ,'.h5'];
%h5 = h5info(hd5name)

disp(['Loading ' hd5name]);
h5tbl = h5read(hd5name,'/table');

ind = logical(h5tbl.ProbabilityOfLabel1);

cell_detected_all(:,2) = h5tbl.CenterOfTheObject_1(ind) - img_info.slice_window(1) +2 + padding_width(1); % y
cell_detected_all(:,1) = h5tbl.CenterOfTheObject_0(ind) - img_info.slice_window(3) +2 + padding_width(2); % x
radii = sqrt(h5tbl.SizeInPixels/pi);

if verbose
    figure;
    plot(cell_detected_all(:,1),cell_detected_all(:,2),'.')
    set(gca,'Ydir','Reverse');
    axis image
end

