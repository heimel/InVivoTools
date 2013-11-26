function [newsc,status] = setupextract(sc,nameref,cksds,instruc);

%  [NEWME,STATUS]=SETUPEXTRACT(SC,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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
  scratchmaster = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
	'_master'];
  scratchmaster2 = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
	'_master2'];

  try, 
    g = load(scratchmaster,'-mat');
  catch,
    status = 0; return;
  end;

  % should have data loaded now, now call clustering routines
  csp = g.csp; thecov = g.thecov; spikeloc = g.spikeloc;
  cspn = normalize_data(g.csp,g.thecov,g.normalize);
  fea = cl_extractFeature(sc,cspn,g.dt);%,g.spikeloc); % extract the features
  [cl,ncsp] = docluster(sc,fea,cspn);
  save(scratchmaster2,'fea','cspn','csp','cl','thecov','ncsp','spikeloc','-mat');

disp(['Did Setting up for 2nd extracting ' nameref.name ':' int2str(nameref.ref) '.']);

newsc = sc;
