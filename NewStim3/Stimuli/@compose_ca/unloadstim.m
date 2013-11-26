function [outstim] = unloadstim(cca)

if isloaded(cca)==1,
	ds = getdisplaystruct(cca);
	if ~isempty(ds),
		try,
			ds = struct(ds);
			screen(ds.offscreen,'close');
		catch,
			os = 0;
		end;
	end;
	for i=1:numStims(cca), cca.stimlist{i} = unloadstim(cca.stimlist{i}); end;
	cca.stimulus = setdisplaystruct(cca.stimulus,[]);
	cca.stimulus = unloadstim(cca.stimulus);
end;

outstim = cca;
