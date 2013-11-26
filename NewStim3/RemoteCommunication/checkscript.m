function txt=checkscript(fname)
    refreshnetwork;
    fid = fopen(fname,'rt');
	if fid>0,
		disp('Found file, opening...');
		txt = [];
		while 1,
			line = fgetl(fid);
			if ~isstr(line), break, end;
			txt = [txt sprintf('\n') line];
		end;
		fclose(fid);
	else, txt = []; fclose('all');
	end;
    
