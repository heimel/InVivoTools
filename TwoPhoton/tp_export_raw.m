function tp_export_raw( data, t, record)
%TP_EXPORT_RAW save twophoton ROI timecourses to csv file
%
%  TP_EXPORT_RAW( DATA, T, RECORD)
%     columns of time and df/f are intermingled
%     times for different cells are not necessarily the same
%     because they can be corrected for the duration a frame takes to image
%
% 2011, Alexander Heimel
%

logmsg('Export raw is currently not implemented.');
return


sfname = tpscratchfilename(record,[],'raw','csv');
m = [t{1,:} ; data{1,:}];
m=reshape(m,size(m,1)/2,size(m,2)*2);
dlmwrite(sfname,m)
for interval = 1:size(data,1)
    m = [t{1,:} ; data{1,:}];
    m=reshape(m,size(m,1)/2,size(m,2)*2);
    dlmwrite(sfname,m,'-append')
end
disp(['TP_EXPORT_RAW: export raw data as ' sfname ]);

