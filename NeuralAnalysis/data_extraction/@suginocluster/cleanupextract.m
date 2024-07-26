function [newsc,status] = cleanupextract(sc,nameref,cksds,instruc);

%  [NEWME,STATUS]=CLEANUPEXTRACT(SC,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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

newsc = sc; status = 1;
return;


p = getscratchdirectory(cksds,1);
scratchmaster = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
    '_master'];


T = gettests(cksds,nameref.name,nameref.ref);

spiketimes = []; intervals = []; typestr = '';
idx = []; csp = []; cest = []; stype = []; stime = [];

for t=1:length(T),
   scratchfilename = [ p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
        '_' T{t} '_' me.MEparams.scratchfile];
   g = load(scratchfilename,'-mat');
   aqinfo = g.aqinfo;
   if g.start<0, % don't include
   else,
      stmp=[];
      intervals = [intervals ; g.start g.start+g.reps_completed*SMPLNG];
      for j=1:g.reps_completed, typestr = g.aqinfo.type;
         ns = sprintf('%.3d',j);
         eval(['idx = [ idx length(stmp)+g.idx_' ns '''];']);
         eval(['stmp = [ stmp g.start+(j-1)*SMPLNG+g.aqinfo.samp_dt*g.stime_' ns '''];']);
         eval(['stime = [ stime (j-1)*fix(SMPLNG/g.aqinfo.samp_dt)+g.stime_' ns '''];']);
         eval(['csp = [ csp g.csp_' ns '];']);
         eval(['stype = [ stype g.stype_' ns '''];']);
         eval(['cest = [ cest g.cest_' ns '''];']);
      end;
      spiketimes = [ spiketimes stmp];
   end;
end;

scratchfilecname = [p 'ME_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
        '_' me.MEparams.scratchfile ],
  % should exist
eval(['load ' scratchfilecname ' -mat']);

save(scratchmaster,'stmp','idx','csp','stype','cest','stime','thecov','-mat');

[px,expf] = getexperimentfile(cksds,1);

cellname = [me.MEparams.event_type_string '_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
             '_999_' expf me.MEparams.scratchfile ];
cellname(find(cellname=='-'))='_'; %disp(cellname)
%eval([cellname '= cksmultipleunit(intervals,'''','''',spiketimes,wd);']);
%intervals,
thecell = cksmultipleunit(intervals,'','',spiketimes,me);
saveexpvar(cksds,thecell,cellname,1);
%eval(['save ' px ' ' cellname ' -append -mat']);

disp(['Cleaning up extraction of ' nameref.name ':' int2str(nameref.ref) '.']);

status = 1;
