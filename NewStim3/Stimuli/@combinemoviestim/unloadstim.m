function [outstim] = unloadstim(cms)

if isloaded(cms)==1,
	p = getparameters(cms);
	p.script = unloadStimScript(p.script);
	ds = getdisplaystruct(cms);
	if ~isempty(ds),
		try,
			ds = struct(ds);
			screen(ds.offscreen,'close');
		catch,
			os = 0;
		end;
	end;
	cms.stimulus = setdisplaystruct(cms.stimulus,[]);
	cms.stimulus = unloadstim(cms.stimulus);
end;

outstim = cms;
