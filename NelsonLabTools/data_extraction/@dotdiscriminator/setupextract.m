function [newdd,status] = setupextract(dd,nameref,cksds,instruc);

%  [NEWDD,STATUS]=SETUPEXTRACT(DD,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
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
  scratchfilename = [p 'DD_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
	'_' dd.DDparams.scratchfile ],

  sf.dd = [];
  if exist(scratchfilename),
     sf = load(scratchfilename,'-mat');
  end;
  if ~(dd==sf.dd), % if no prev dd or old dd is not equal to current, then run
    g = gettests(cksds,nameref.name,nameref.ref);
    g = g{1};
    fname = [p2 g filesep 'acqParams_out'];
    r = loadStructArray(fname);
    z = namerefind(r,nameref.name,nameref.ref);
    if ~z, error('Name/ref pair not actually in directory.'); end;
    fa = r(z).fname;
    fname = [p2 g filesep 'r001_' fa],
	byts=dir(fname);
    %[s,w]=dos(['du -b ' fname]);w = str2num(w(1:find(w==9)-1));
    if byts.bytes~=1257702, status = 0;  % if not complete, wait
    else,
       %h = loadIgor(fname); h = dotdiscfilter(dd,h);
       %sd = std(h); m = mean(h);
       %save(scratchfilename,'m','sd','dd','-mat');
    end;
  end;

disp(['Did Setting up for extracting ' nameref.name ':' int2str(nameref.ref) '.']);

newdd = dd;

function ind = namerefind(nameref_str,name,ref)
 % returns -1 if not there, or the index of the nameref pair
ind = -1;
for i=1:length(nameref_str),
        if strcmp(nameref_str(i).name,name)&nameref_str(i).ref==ref,
                ind=i; i=length(nameref_str)+1;
        end;
end;

