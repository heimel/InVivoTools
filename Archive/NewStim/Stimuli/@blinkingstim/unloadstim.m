function [outstim] = unloadstim(BLstim)

if isloaded(BLstim) == 1,
	ds = struct(getdisplaystruct(BLstim.stimulus));
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
	BLstim.stimulus = setdisplaystruct(BLstim.stimulus,[]);
	BLstim.stimulus = unloadstim(BLstim.stimulus);
end;

outstim = BLstim;
