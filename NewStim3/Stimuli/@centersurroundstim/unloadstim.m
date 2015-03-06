function [outstim] = unloadstim(CSSstim)

if isloaded(CSSstim) == 1,
	ds = struct(getdisplaystruct(CSSstim.stimulus));
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
	CSSstim.stimulus = setdisplaystruct(CSSstim.stimulus,[]);
	CSSstim.stimulus = unloadstim(CSSstim.stimulus);
end;

outstim = CSSstim;
