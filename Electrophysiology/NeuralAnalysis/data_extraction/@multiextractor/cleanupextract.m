function [newme,status] = cleanupextract(me,nameref,cksds,instruc);

%  [NEWME,STATUS]=CLEANUPEXTRACT(ME,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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

newme = me;



p = getscratchdirectory(cksds,1);
scratchmaster = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
    '_master'];


T = gettests(cksds,nameref.name,nameref.ref);

Ta = isactive(cksds,T);
if all(Ta==0), status = 1; return; end;

spiketimes = []; intervals = []; typestr = '';
idx = []; csp = []; cest = []; stype = []; stime = [];
stmp=[];
for t=1:length(T),
   %if isactive(cksds,T{t}),
   fin=1;
   scratchfilename=[ p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
        '_' T{t} '_' me.MEparams.scratchfile];
   try, g = load(scratchfilename,'-mat');
   catch, if ~isactive(cksds,T{t}),fin=0;
            else,error(['Could not open file ' scratchfilename '.']); end; end;
   if fin,
     aqinfo = g.aqinfo;
     if g.start<0, % don't include
     else,
      intervals = [intervals ; g.start g.start+g.reps_completed*SMPLNG];
      for j=1:g.reps_completed, typestr = g.aqinfo.type;
         ns = sprintf('%.3d',j);
         eval(['idx = [ idx length(stmp)+g.idx_' ns '''];']);
         eval(['stmp = [ stmp g.start+(j-1)*SMPLNG+g.aqinfo.samp_dt*g.stime_' ns '(g.idx_' ns ')''];']);
         eval(['stime = [ stime (j-1)*fix(SMPLNG/g.aqinfo.samp_dt)+g.stime_' ns '(g.idx_' ns ')''];']);
         eval(['csp = [ csp g.csp_' ns '];']);
         eval(['stype = [ stype g.stype_' ns '(g.idx_' ns ')''];']);
         eval(['cest = [ cest g.cest_' ns '''];']);
      end;
     end;
   end;
end;
scratchfilecname = [p 'ME_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
        '_' me.MEparams.scratchfile ],
  % should exist
eval(['load ' scratchfilecname ' -mat']);

dt = aqinfo.samp_dt;
spikeloc = ceil(me.MEparams.pre_time/dt) + 1;
normalize = me.MEparams.normalize;
datadir = me.MEparams.datadir;
save(scratchmaster,'stmp','idx','csp','stype','cest','stime','thecov','dt','spikeloc','normalize','datadir','intervals','-mat');

[px,expf] = getexperimentfile(cksds,1);

cellname = [me.MEparams.event_type_string '_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
             '_999_' expf me.MEparams.scratchfile ];
cellname(find(cellname=='-'))='_'; %disp(cellname)
thecell = cksmultipleunit(intervals,'','',stmp,me);
saveexpvar(cksds,thecell,cellname,1);

disp(['Cleaning up extraction of ' nameref.name ':' int2str(nameref.ref) '.']);

status = 1;
