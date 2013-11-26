function [outstim] = unloadstim(qts)

StimWindowGlobals;

if isloaded(qts)==1,
	ds = struct(getdisplaystruct(qts));
	try, Screen('CloseMovie',ds.userfield.movie); end;
	qts.stimulus = setdisplaystruct(qts.stimulus,[]);
	qts.stimulus = unloadstim(qts.stimulus);
end;

outstim = qts;
