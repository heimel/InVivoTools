function [newdd,status] = extractdir(dd,thedir,aqinfo,cksds,instruc);

%  [NEWDD,STATUS]=EXTRACTDIR(DD,THEDIR,ACQ_OUT_INFO,THECKSDIRSTRUCT,INSTRUC)
%
%  Perform extraction operation on the data described by ACQ_OUT_INFO in the
%  given directory (THEDIR) associated with THECKSDIRSTRUCT according to the
%  instructions given in INSTRUC.
%
%  INSTRUC has the following fields:
%     extractincompletedir (0 or 1)      : 1 means attempt to extract data
%                                        :   from directory where data is still
%                                        :   coming in
%
%  STATUS is one of -1 (error), 0 (no error but not operation not complete)
%  1 (operation complete).
%
%  See also:  CKSDIRSTRUCT, INSTRUC

status = 1; newdd = dd;

p = getscratchdirectory(cksds,1);
p2= getpathname(cksds);

disp(['DD: Extracting ' ...
	aqinfo.name ':' int2str(aqinfo.ref) ' in directory ' thedir '.']);

scratchfilename = [ p 'DD_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
	'_' thedir '_' dd.DDparams.scratchfile],

startat=1; start=-1; reps_completed = 0;

if exist(scratchfilename),
	g = load(scratchfilename,'reps_completed','start','dd','-mat');
	if g.start~=-1&g.dd==dd, return; % we've done this one
        elseif ~(g.dd==dd), % new parameters, so delete old scratch file
          eval(['delete ' scratchfilename]);
	else, startat=g.reps_completed;  % we're resuming
        end;
end;
if ~exist(scratchfilename),
   eval(['save ' scratchfilename ' reps_completed aqinfo start dd -mat;']);
end;

for i=startat:aqinfo.reps,
   fname = [p2 thedir filesep 'r' sprintf('%.3d',i) '_' aqinfo.fname];
   if exist(fname),
     d = loadIgor(fname); d = dotdiscfilter(dd,d); size(d),
     eval(['samps_' sprintf('%.3d',i) ' = dotdisc(dd,d,dd.DDparams.dots'');']);
     eval(['length(samps_' sprintf('%.3d',i) '),']);
     eval(['save ' scratchfilename ' samps_' sprintf('%.3d',i) ' -append -mat;']);
   else, status = 0; break; end;
end;
reps_completed = i;
eval(['save ' scratchfilename ' reps_completed -append -mat;']);

if status==1,
   p3 = [p2 thedir filesep 'stims.mat'];
   if exist(p3),
      s=load(p3);
      start = s.start;
      eval(['save ' scratchfilename ' start -append -mat;']);
   else, status = 0; return;
   end;
end;

