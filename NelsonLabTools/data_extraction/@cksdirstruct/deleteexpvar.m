function deleteexpvar(cksds,pattern)
%  DELETEEXPVAR(MYCKSDIRSTRUCT,PATTERN)
%
%    Deletes an experiment variable from the CKSDIRSTRUCT given.
%
%    Wildcards using '*' are allowed.

fn = getexperimentfile(cksds);
if exist(fn, 'file')
    g = load(fn,'-mat');
    n = fieldnames(g);
    delete(fn);
    for i=1:length(n)
        if ~streq(n{i},pattern)
            eval([n{i} '=g.' n{i} ';']);
            if ~exist(fn,'file')
                save(fn,n{i},'-mat');
            else
                save(fn,n{i},'-append','-mat');
            end
        end
    end
else
    warning('DELETEEXPVAR:  No experiment found file to open.');
end
