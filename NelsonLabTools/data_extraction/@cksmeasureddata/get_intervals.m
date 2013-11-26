function [inter,ncksmd] = get_intervals(cksmd)

% [INTER,NCKSMD] = GET_INTERVALS(CKSMEASDATA)
%
% Returns the intervals over which data was measured.  Returns also an updated
% CKSMEASUREDDATA object.  It is not necessary to retreive the updated
% structure, but subsequent calls to GET_INTERVALS will be faster because
% information about the directory tree is added.
%
% See also:  CKSMEASUREDDATA
if exist(cksmd.thedir)==7,
  dl = dirstrip(dir(cksmd.thedir));
  prefix = fixpath(cksmd.thedir);
  sztest=0;direq=1;
  if ~isempty(cksmd.olddirlist),
	szdl=size(dl);
  	sztest = szdl(1)==size(cksmd.olddirlist,1); jj=1;
	while direq&jj<=szdl(1),
		direq=strcmp(dl(jj).name,cksmd.olddirlist(jj).name);
		if direq, direq=strcmp(dl(jj).date,cksmd.olddirlist(jj).date);end;
	jj=jj+1;
	end;
  end;
  if ~(sztest&direq),
     % re-do everything if folder names,mod dates not ==
     %disp('re-doing everthing.');
     cksmd.tint = []; j = []; dirnames = {}; acqs = [];
     for i=1:length(dl),
       pf = fixpath([prefix dl(i).name]);
       if (exist([pf 'acqParams_out'])==2)&(exist([pf 'stims.mat'])==2),
          try,
               acq = loadStructArray([pf 'acqParams_out']);
               [b,k]=intersect({acq.name},cksmd.name);
               if ~isempty(b),
                  [b,k2]=intersect([acq(k).ref],cksmd.ref);
                  if ~isempty(b),
                    %disp(['Here : k=' mat2str(k) ',k2=' mat2str(k2) '.']);
                    g = load([pf 'stims.mat'],'start','-mat');
                    cksmd.tint = [cksmd.tint ; g.start+...
                         [0 cksmd.ckslen*acq(k(k2)).reps-acq(k(k2)).samp_dt];];
                    j = [j i]; acqs = [acqs acq(k(k2))];
                    dirnames = { dirnames{:} dl(i).name };
                  end;
               end;
          catch, end;
       end; 
     end;
     % put them in order of intervals
     cksmd.olddirlist = dl;
     if ~isempty(cksmd.tint),
       [z,zi] = sort(cksmd.tint(:,1));
       cksmd.tint = cksmd.tint(zi,:);
       cksmd.dirlist = dl(j(zi));
       cksmd.acq = acqs(zi);
       cksmd.dirnames = {dirnames{zi}};
     end;
  end;
else,
  error(['Could not read directory ' thedir ]);
end;

cksmd = set_intervals(cksmd,cksmd.tint);
inter = cksmd.tint;
ncksmd = cksmd;
