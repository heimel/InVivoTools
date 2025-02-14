function [newwd,status] = extractdir(wd,thedir,aqinfo,cksds,instruc);

%  [NEWWD,STATUS]=EXTRACTDIR(WD,THEDIR,ACQ_OUT_INFO,THECKSDIRSTRUCT,INSTRUC)
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

status = 1; newwd = wd;

thresh1 = wd.WDparams.thresh1; thresh2 = wd.WDparams.thresh2;
if wd.WDparams.threshmethod==0,
  p = getscratchdirectory(cksds,1);
  scratchfilename = [p 'WD_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
        '_' wd.WDparams.scratchfile ],
  % should exist
  pf = load(scratchfilename,'-mat'); sd = pf.sd; m = pf.m;
  thresh1=thresh1*sd+m; thresh2=thresh2*sd+m;
end;

p = getscratchdirectory(cksds,1);
p2= getpathname(cksds);

disp(['WD: Extracting ' ...
	aqinfo.name ':' int2str(aqinfo.ref) ' in directory ' thedir '.']);

scratchfilename = [ p 'WD_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
	'_' thedir '_' wd.WDparams.scratchfile],

startat=1; start=-1; reps_completed = 0;

if exist(scratchfilename),
	g = load(scratchfilename,'reps_completed','start','wd','-mat');
	if g.start~=-1&g.wd==wd, return; % we've done this one
        elseif ~(g.wd==wd), % new parameters, so delete old scratch file
          eval(['delete ' scratchfilename]);
	else, startat=g.reps_completed;  % we're resuming
        end;
end;
if ~exist(scratchfilename),
   eval(['save ' scratchfilename ' reps_completed aqinfo start wd -mat;']);
end;



for i=startat:aqinfo.reps,
   fname = [p2 thedir filesep 'r' sprintf('%.3d',i) '_' aqinfo.fname];
   if exist(fname),
     d = loadIgor(fname); d = winddiscfilter(wd,d); size(d),
     eval(['samps_' sprintf('%.3d',i) ' = winddisc(wd,d,thresh1,thresh2);']);
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

