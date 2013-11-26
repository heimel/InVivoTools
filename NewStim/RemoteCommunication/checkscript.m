function txt=checkscript(fname)
	if exist(fname)==2,
		disp('Found file, opening...');
		fid=fopen(fname,'rt');
		txt = [];
		while 1,
			line = fgetl(fid);
			if ~isstr(line), break, end;
			txt = [txt sprintf('\n') line];
		end;
		fclose(fid);
	else, txt = [];
	end;
