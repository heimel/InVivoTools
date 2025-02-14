function [newme,status] = extractdir(me,thedir,aqinfo,cksds,instruc);

%  [NEWME,STATUS]=EXTRACTDIR(ME,THEDIR,ACQ_OUT_INFO,THECKSDIRSTRUCT,INSTRUC)
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

status = 1; newme = me;

p = getscratchdirectory(cksds,1);
scratchfilename = [p 'ME_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
        '_' me.MEparams.scratchfile ],
  % should exist
eval(['load ' scratchfilename ' -mat']);

p2= getpathname(cksds);

disp(['ME: Extracting ' ...
	aqinfo.name ':' int2str(aqinfo.ref) ' in directory ' thedir '.']);

scratchfilename = [ p 'ME_' aqinfo.name '_' sprintf('%.4d',aqinfo.ref) ...
	'_' thedir '_' me.MEparams.scratchfile],

startat=1; start=-1; reps_completed = 0;

if exist(scratchfilename),
	g = load(scratchfilename,'reps_completed','start','me','-mat');
	if g.start~=-1&g.me==me, return; % we've done this one
        elseif ~(g.me==me), % new parameters, so delete old scratch file
          eval(['delete ' scratchfilename]);
	else, startat=g.reps_completed; % we're resuming
        end;
end;
if ~exist(scratchfilename),
  eval(['save ' scratchfilename ' reps_completed aqinfo start me -mat;']);
end;

for i=startat:aqinfo.reps,
   fname1 = [p2 thedir filesep 'r' sprintf('%.3d',i) '_' aqinfo.fname '_c01'];
   fname2 = [p2 thedir filesep 'r' sprintf('%.3d',i) '_' aqinfo.fname '_c02'];
   fname3 = [p2 thedir filesep 'r' sprintf('%.3d',i) '_' aqinfo.fname '_c03'];
   fname4 = [p2 thedir filesep 'r' sprintf('%.3d',i) '_' aqinfo.fname '_c04'];
   if eac(fname1)&eac(fname2)&eac(fname3)&eac(fname4),
      h=[loadIgor(fname1)';loadIgor(fname2)';loadIgor(fname3)';...
           loadIgor(fname4)';];
      h(1,:) = mefilter(me,h(1,:)); h(2,:) = mefilter(me,h(2,:));
      h(3,:) = mefilter(me,h(3,:)); h(4,:) = mefilter(me,h(4,:));
      h = h';
      st=sprintf('%.3d',i);
      v1 = ['stime_' st];v2 = ['stype_' st];v3 = ['csp_' st];v4 = ['cest_' st];
      v5 = ['idx_' st];
      eval(['[' v1 ',' v2 ',' v3 ',' v4 ',' v5 ']=muex(me,h,thecov,aqinfo.samp_dt,st);']);
      eval(['length(stime_' sprintf('%.3d',i) '),']);
      eval(['save ' scratchfilename ' ' v1 ' ' v2 ' ' v3 ' ' v4 ' ' v5 ' me -append -mat;']);
   else, status = 0; break; end;
end;
reps_completed = i;
eval(['save ' scratchfilename ' reps_completed me -append -mat;']);

if status==1,
   p3 = [p2 thedir filesep 'stims.mat'];
   if exist(p3),
      s=load(p3);
      start = s.start;
      eval(['save ' scratchfilename ' start me -append -mat;']);
   else, status = 0; return;
   end;
end;

function b = eac(fname) % exist and complete
b = 1;
if exist(fname),
	a = dir(fname);
	if a.bytes~=1257702,
    b=0;end;
else, b = 0;
end;
