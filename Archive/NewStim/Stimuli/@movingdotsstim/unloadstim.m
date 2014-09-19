function [outstim] = unloadstim(MDstim)

if isloaded(MDstim) == 1,
	MDstim.stimulus = setdisplaystruct(MDstim.stimulus,[]);
	MDstim.stimulus = unloadstim(MDstim.stimulus);
end;

outstim = MDstim;
