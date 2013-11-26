function [outstim] = unloadstim(charlottestim)

if isloaded(charlottestim) == 1,
	ds = struct(getdisplaystruct(charlottestim.stimulus));
	os = ds.offscreen;
	for i=1:length(os),
		if os(i)~=0,
			try,
				screen(os(i),'close');
            catch,
				os(i) = 0;
			end;
		end;
	end;
	SGSstim.stimulus = setdisplaystruct(charlottestim.stimulus,[]);
	SGSstim.stimulus = unloadstim(charlottestim.stimulus);
end;

outstim = charlottestim;
