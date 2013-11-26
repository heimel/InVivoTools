function [newwdc,status] = cleanupextract(wdc,theme,nameref,cksds,instruc);

%  [NEWME,STATUS]=CLEANUPEXTRACT(WDC,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
%
%  Perform cleanup for extraction operation on the data described by NAMEREF in
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

%  SMPLNG = 10, samp length
   SMPLNG = 10;

newwdc = wdc; status = 1;

p = getscratchdirectory(cksds,1);
scratchmaster = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
    '_master'];
outname = [p 'WDC_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
        '_master'];
[px,expf] = getexperimentfile(cksds,1);

try, 
  L = load(scratchmaster,'-mat');
  ds = load(outname,'-mat');
  ds = ds.ds;
catch, 
  disp(['wdcluster cannot open cluster definition files: ' ...
      nameref.name '_' sprintf('%.4d',nameref.ref) '.']);
  status = 0; return;
end;

if ds.feature==1,
  fea = wdc_extractPeaks(L.csp,L.spikeloc,1);
elseif ds.feature==2,
  fea = wdc_extractRaw(L.csp,L.spikeloc)';
end;

me = struct(theme);
ets = me.MEparams.event_type_string;
cellnamedel = [ets '_' nameref.name '_' sprintf('%.4d',nameref.ref) '_*_' expf me.MEparams.scratchfile];
deleteexpvar(cksds,cellnamedel); % delete all old representations

inc = 0;
inds = wdc_clusterall(ds.cellcl,fea);
length(ds.cellcl),
for i=1:length(ds.cellcl),
  spiketimes = L.stmp(find(inds(:,i)));
  if ~isempty(spiketimes),
    cellname = [ets '_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
             '_' sprintf('%.3d',inc)  '_' expf me.MEparams.scratchfile ];
    cellname(find(cellname=='-'))='_'; %disp(cellname)
    thecell = cksmultipleunit(L.intervals,'','',spiketimes,struct('primary',theme,'secondary',wdc));
    disp(['Adding ' cellname '.']);
    saveexpvar(cksds,thecell,cellname,0);
    inc = inc + 1;
  end;
end;

disp(['Cleaning up extraction of ' nameref.name ':' int2str(nameref.ref) '.']);
