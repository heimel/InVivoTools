function [outstim] = unloadstim(SGSstim)

if isloaded(SGSstim) == 1,
	ds = struct(getdisplaystruct(SGSstim.stimulus));
	os = ds.offscreen;
	for i=1:length(os),
		if os(i)~=0,
			try
				Screen(os(i),'close');
            catch
				os(i) = 0;
			end;
		end;
	end;
	SGSstim.stimulus = setdisplaystruct(SGSstim.stimulus,[]);
	SGSstim.stimulus = unloadstim(SGSstim.stimulus);
end;

outstim = SGSstim;
