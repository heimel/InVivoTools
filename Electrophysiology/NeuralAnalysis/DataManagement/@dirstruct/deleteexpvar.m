function deleteexpvar(cksds,variablenametobedeleted)

%  DELETEEXPVAR(MYDIRSTRUCT,NAME)
%
%    Deletes an experiment variable from the DIRSTRUCT given.
%
%    Wildcards using '*' are allowed.

fn = getexperimentfile(cksds);
if exist(fn,'file')
    g = load(fn);
    n = fieldnames(g);
    delete(fn);
    for i=1:length(n)
        if ~streq(n{i},variablenametobedeleted)
            eval([n{i} '=g.' n{i} ';']);
            if ~exist(fn,'file')
                save(fn,n{i},'-v7');
            else
                save(fn,n{i},'-append','-v7');
            end
        end
    end
else
    warning('DELETEEXPVAR:  No experiment found file to open.');
end
