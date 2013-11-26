function [cells,cellnames] = analyzegeneric2pdata(dirname, saveit)

ds = dirstruct(dirname);

[cells,cellnames] = tpdoresponseanalysis(ds);

if saveit,
	disp(['Saving results back to file']);
	saveexpvar(ds,cells,cellnames,0);
end;
