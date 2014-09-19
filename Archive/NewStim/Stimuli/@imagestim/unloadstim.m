function [outstim] = unloadstim(ISstim)

if isloaded(ISstim) == 1,
	ds = struct(getdisplaystruct(ISstim.stimulus));
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
	ISstim.stimulus = setdisplaystruct(ISstim.stimulus,[]);
	ISstim.stimulus = unloadstim(ISstim.stimulus);
end;

outstim = ISstim;