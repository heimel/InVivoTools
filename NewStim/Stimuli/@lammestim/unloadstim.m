function [outstim] = unloadstim(stim)

if isloaded(stim) == 1,
	ds = struct(getdisplaystruct(stim.stimulus));
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
	stim.stimulus = setdisplaystruct(stim.stimulus,[]);
	stim.stimulus = unloadstim(stim.stimulus);
end;

outstim = stim;
