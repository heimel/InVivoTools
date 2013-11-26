function [outstim] = unloadstim(RCGstim)

if isloaded(RCGstim) == 1,
	ds = struct(getdisplaystruct(RCGstim.stimulus));
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
	RCGstim.stimulus = setdisplaystruct(RCGstim.stimulus,[]);
	RCGstim.stimulus = unloadstim(RCGstim.stimulus);
end;

outstim = RCGstim;
