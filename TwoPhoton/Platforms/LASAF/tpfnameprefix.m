function fnameprefix=tpfnameprefix(dirname,channel)

fname = dir([dirname filesep '*_t*1.tif']);
if isempty(fname),
	fname = dir([dirname filesep '*_t*1.TIFF']);
	if isempty(fname),
		fname = dir([dirname filesep '*_t*1.tiff']);
		if isempty(fname),
			fname = dir([dirname filesep '*_t*1.TIF']);
		end;
	end;
end;

strind = findstr(fname(end).name,'_t');

fnameprefix = fname(end).name(1:strind(end)-1);
