function [outstim] = unloadstim(LBs)

if isloaded(LBs)==1,
	ds = struct(getdisplaystruct(LBs));
	os = ds.offscreen;
	try,
		screen(os,'close');
	catch,
		os = 0;
	end;
	LBs.stimulus = setdisplaystruct(LBs.stimulus,[]);
	LBs.stimulus = unloadstim(LBs.stimulus);
end;

outstim = LBs;
