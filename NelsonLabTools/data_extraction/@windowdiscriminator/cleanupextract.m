function [newwd,status] = cleanupextract(wd,nameref,cksds,instruc);

%  [NEWWD,STATUS]=CLEANUPEXTRACT(WD,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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

newwd = wd;

p = getscratchdirectory(cksds,1);

T = gettests(cksds,nameref.name,nameref.ref);

Ta = isactive(cksds,T);
if isempty(Ta), status = 1; return; end;

spiketimes = []; intervals = []; typestr = '';

for t=1:length(T),
  %if isactive(cskds,T{i}),
  fin=1;
  scratchfilename = [ p 'WD_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
        '_' T{t} '_' wd.WDparams.scratchfile];
  try,g = load(scratchfilename,'-mat');
  catch,if ~isactive(cksds,T{t}),fin=0;
        else,error(['Could not open file ' scratchfilename '.']); end; end;
  if fin,
   if g.start<0, % don't include
   else,
      stmp=[];
      intervals = [intervals ; g.start g.start+g.reps_completed*SMPLNG];
      for j=1:g.reps_completed, typestr = g.aqinfo.type;
         eval(['stmp = [ stmp g.start+(j-1)*SMPLNG+g.aqinfo.samp_dt*g.samps_' sprintf('%.3d',j) '];']);
      end;
      spiketimes = [ spiketimes stmp];
   end;
  end;
end;

[px,expf] = getexperimentfile(cksds,1);

cellname = [wd.WDparams.event_type_string '_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
             '_001_' expf wd.WDparams.scratchfile ];
cellname(find(cellname=='-'))='_'; disp(cellname)
%eval([cellname '= cksmultipleunit(intervals,'''','''',spiketimes,wd);']);
intervals,
thecell = cksmultipleunit(intervals,'','',spiketimes,wd);
saveexpvar(cksds,thecell,cellname,1);
%eval(['save ' px ' ' cellname ' -append -mat']);

disp(['Cleaning up extraction of ' nameref.name ':' int2str(nameref.ref) '.']);

status = 1;
