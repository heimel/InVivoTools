function [outstim] = unloadstim(SMSstim)

if isloaded(SMSstim) == 1,
	ds = struct(getdisplaystruct(SMSstim.stimulus));
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
	SMSstim.stimulus = setdisplaystruct(SMSstim.stimulus,[]);
	SMSstim.stimulus = unloadstim(SMSstim.stimulus);
end;

outstim = SMSstim;
