function [newac,status] = cleanupextract(ac,theme,nameref,cksds,instruc);

%  [NEWAC,STATUS]=CLEANUPEXTRACT(AC,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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

newac = ac; status = 1;


p = getscratchdirectory(cksds,1);
scratchmaster = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
    '_master'];
outname = [p 'AC_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
        '_master'];
[px,expf] = getexperimentfile(cksds,1);

try,
  L = load(scratchmaster,'-mat');
  ds = load(outname,'-mat');
catch,
  disp(['accluster cannot open cluster class files: ' ...
      nameref.name '_' sprintf('%.4d',nameref.ref) '.']);
  status = 0; return;
end;


scratchfile='scratchfile';
ets='ets';
if isobject(theme)
  me = struct(theme);
  scratchfile=me.MEparams.scratchfile;
  ets = me.MEparams.event_type_string;
  cellnamedel = [ets '_' nameref.name '_' sprintf('%.4d',nameref.ref)...
                 '_*_' expf scratchfile];
  deleteexpvar(cksds,cellnamedel);  % delete all old representations
end

inc=0;
for i=1:ds.maxclass,
  spiketimes = L.stmp(   find( ds.classes(:,1)==i )     );
  if ~isempty(spiketimes),
    cellname = [ets '_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
             '_' sprintf('%.3d',inc)  '_' expf scratchfile ];
    thecell = cksmultipleunit(L.intervals,'','',spiketimes,struct('primary',theme,'secondary',ac));
    disp(['Adding ' cellname '.']); 

    saveexpvar(cksds,thecell,cellname,0);
    inc = inc + 1;
  end;
end;




disp(['Cleaning up extraction of ' nameref.name ':' int2str(nameref.ref) '.']);


