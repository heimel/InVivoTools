function [newwdc,status] = setupextract(wdc,theme,nameref,cksds,instruc);

%  [NEWWDC,STATUS]=SETUPEXTRACT(WDC,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
%
%  Perform setup for extraction operation on the data described by NAMEREF in
%  the directorys associated with THECKSDIRSTRUCT according to the instructions
%  given in INSTRUC.
%
%  INSTRUC has the following fields:
%     extractincompletedir (0 or 1)      : 1 means will attempt to extract data
%                                        :   from directory where data is still
%                                        :   coming in
%
%  STATUS is one of -1 (error), 0 (no error but not operation not complete)
%  1 (operation complete).
%
%  See also:  CKSDIRSTRUCT, INSTRUC

status = 1;

  p = getscratchdirectory(cksds,1);
  % needs to be fixed
  scratchmaster = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
	'_master'];
  outname = [p 'WDC_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
  	'_master'];

%  try, 
    if exist(outname),
      disp('Loading outname');
      load(outname,'-mat');
    end;
    L = load(scratchmaster,'-mat');
    if ~exist('ds')|(ds.redisplay&(~(eqlen(L.stime,ds.stime))))|(~(wdc==ds.wdc)),
       if ~exist('ds'), ds = []; end;
       graph_clust(wdc,L,outname,ds);
    end;
%  catch,
%    status = 0; return;  % no data
%  end;

  % should have data loaded now, now call clustering routines

disp(['Did Setting up for 2nd extracting ' nameref.name ':' int2str(nameref.ref) '.']);

newwdc = wdc;
