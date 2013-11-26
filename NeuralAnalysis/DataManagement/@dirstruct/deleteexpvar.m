function deleteexpvar(cksds,variablenametobedeleted)

%  DELETEEXPVAR(MYDIRSTRUCT,NAME)
%
%    Deletes an experiment variable from the DIRSTRUCT given.
%
%    Wildcards using '*' are allowed.

fn = getexperimentfile(cksds);
if exist(fn)==2,
  g = load(fn,'-mat');
  n = fieldnames(g);
  delete(fn);
  for i=1:length(n),
     if ~streq(n{i},variablenametobedeleted),
       eval([n{i} '=g.' n{i} ';']);
       if exist(fn)~=2, save(fn,n{i},'-mat');
       else, save(fn,n{i},'-append','-mat'); end;
     end;
  end; 
else,
  warning('DELETEEXPVAR:  No experiment found file to open.');
end;
