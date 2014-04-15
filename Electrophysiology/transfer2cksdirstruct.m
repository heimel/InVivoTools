function transfer2cksdirstruct(cells,datapath)
%TRANSFERCELLS Transfers cells from loadcells to the cksdirstruct
%
%    TRANSFERCELLS(CELLS,CKSDS)
%
% 2014, Alexander Heimel

cksds=cksdirstruct(datapath);

getexperimentfile(cksds,1); % to create experiment file if necessary
deleteexpvar(cksds,'cell*'); % delete all old representations

for cl=1:length(cells)
   acell=cells(cl);
   thecell=cksmultipleunit(acell.intervals,acell.desc_long,...
		acell.desc_brief,acell.data,acell.detector_params);
    saveexpvar(cksds,thecell,acell.name,1);
end

return


