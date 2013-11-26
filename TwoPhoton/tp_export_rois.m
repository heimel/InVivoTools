function tp_export_rois( record )
%TP_EXPORT_ROIS saves twophoton ROIs to csv file
%
%  TP_EXPORT_ROIS( record )
%
%
% 2012, Alexander Heimel
%

savedir = pwd;
cd(getdesktopfolder);
sfname = tpscratchfilename(record,[],'rois','csv');
[~,sfname] = fileparts(sfname);
sfname = [sfname '.csv'];
[filename,pathname] = uiputfile('*.csv','Export ROIs',sfname);
cd(savedir);
sfname = fullfile(pathname,filename);
delimiter = char(9);
saveStructArray(sfname,record.ROIs.celllist,1,delimiter,true)

%m = [t{1,:} ; data{1,:}];
%m=reshape(m,size(m,1)/2,size(m,2)*2);
%dlmwrite(sfname,m)

disp(['TP_EXPORT_ROIS: exported rois as ' sfname ]);

global rois
rois = record.ROIs.celllist;
disp('TP_EXPORT_ROIS: ROIs available as global rois');
