function [outstim] = unloadstim(PSstim)

if isloaded(PSstim) == 1,
	ds = struct(getdisplaystruct(PSstim.stimulus));
	os = ds.offscreen;
	for i=1:length(os),
		if os(i)~=0,
			try,
				Screen(os(i),'close');
			catch,
				os(i) = 0;
			end;
		end;
	end;
	PSstim.stimulus = setdisplaystruct(PSstim.stimulus,[]);
	PSstim.stimulus = unloadstim(PSstim.stimulus);
end;

outstim = PSstim;
