function [outstim] = unloadstim(ws)

if isloaded(ws)==1,
	ds = struct(getdisplaystruct(ws));
	ws.stimulus = setdisplaystruct(ws.stimulus,[]);
	ws.stimulus = unloadstim(ws.stimulus);
end;

outstim = ws;
