function fnameprefix=tpfnameprefix(dirname,channel)

fname = dir([dirname filesep '*Cycle001_Ch' int2str(channel) '_000001.tif']); 
fname = fname.name;
fnameprefix = fname(1:strfind(fname,'Cycle')-1);