function [newme,status] = setupextract(me,nameref,cksds,instruc);

%  [NEWME,STATUS]=SETUPEXTRACT(ME,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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
  p2 = getpathname(cksds);

  % compute standard deviation
  scratchfilename = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
	'_' me.MEparams.scratchfile ],

  sf.me = [];
  if exist(scratchfilename),
     sf = load(scratchfilename,'-mat');
  end;
  if ~(me==sf.me), % if no prev me or old me is not equal to current, then run
    g = gettests(cksds,nameref.name,nameref.ref);
    g = g{1};
    fname = [p2 g filesep 'acqParams_out'];
    r = loadStructArray(fname);
    z = namerefind(r,nameref.name,nameref.ref);
    if ~z, error('Name/ref pair not actually in directory.'); end;
    fa = r(z).fname;
    fname1 = [p2 g filesep 'r001_' fa '_c01'],
    fname2 = [p2 g filesep 'r001_' fa '_c02'],
    fname3 = [p2 g filesep 'r001_' fa '_c03'],
    fname4 = [p2 g filesep 'r001_' fa '_c04'],
	byts=dir(fname1);
    if byts.bytes~=1257702, status = 0; end; % if not complete, wait
	byts=dir(fname2);
    if byts.bytes~=1257702, status = 0; end; % if not complete, wait
	byts=dir(fname3);
    if byts.bytes~=1257702, status = 0; end; % if not complete, wait
	byts=dir(fname4);
    if byts.bytes~=1257702, status = 0; end; % if not complete, wait
    if status~=0,
      h=[loadIgor(fname1)';loadIgor(fname2)';loadIgor(fname3)';...
           loadIgor(fname4)';];
      h(1,:) = mefilter(me,h(1,:)); h(2,:) = mefilter(me,h(2,:));
      h(3,:) = mefilter(me,h(3,:)); h(4,:) = mefilter(me,h(4,:));
      h = h';
      stddev = std(h); m = mean(h);
      he = h - repmat(m,size(h,1),1);         % subtract mean
      he = he./repmat(stddev,size(h,1),1); % normalize
      he = sum(he'.^2)';                    % energy
      z = findcovdata(he,me.MEparams.threshcov,...
	max(1,floor((me.MEparams.pre_time+me.MEparams.post_time)/r(z).samp_dt)));
      %themean = mean(h(z,:));
      thecov = cov(h(z,:));

      % find whitened covariance matrix and whitening filter for each channel
     % zd = diff(z)-1;             % compute difference
     % if z(1)==1, z_ = 1; else, z_ = []; end;
     % if z(end)==length(h), z__=length(z); else, z__ = []; end;
     % zdi = [z_; (find(zd))+1; z__;];             % find breaks
     % zdid = diff(zdi);           % how long between breaks?
     % [m,i] = max(zdid);       %    
    %  i = i(1),
    %  zdi(i),(zdi(i+1)),
    %  ci = z(zdi(i):(zdi(i+1)-1));
    %  for i=1:4,
        %BW(i,:)=arburg(h(ci,1),3); H(:,i)=filtfilt(BW(i,:),1,h(:,1));
    %  end;
    %  thewcov = cov(H(z,:));
	BW = []; thewcov = [];
     eval(['save ' scratchfilename ' thecov thewcov BW me -mat']);
    end;
  end;


disp(['Did Setting up for extracting ' nameref.name ':' int2str(nameref.ref) '.']);

newme = me;

function ind = namerefind(nameref_str,name,ref)
 % returns -1 if not there, or the index of the nameref pair
ind = -1;
for i=1:length(nameref_str),
        if strcmp(nameref_str(i).name,name)&nameref_str(i).ref==ref,
                ind=i; i=length(nameref_str)+1;
        end;
end;
