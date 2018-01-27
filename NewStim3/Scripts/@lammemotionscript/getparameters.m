function P = getparameters(S)

%  Part of the NewStim package
%
%  P = GETPARAMETERS(MYSCRIPT)
%
%  Returns the parameters of MYSCRIPT.

P = S.params;


pars = cellfun(@getparameters,get(S));
pars = squeeze(struct2cell(pars));
flds = fieldnames(S.params);
for i=1:size(pars,1)
    c = cat(1,pars{i,:});
    if iscell(c)
        val = cell(1,size(c,2));
        for j=1:size(c,2)
            x = c(:,j);
            if isnumeric(x{1})
                val{j} = unique(cat(1,x{:}));
            else
                val{j} = unique(c(:,j));
            end
        end
    else
        val = unique(c,'rows');
    end
    p.(flds{i}) = val;
    
end
P = p;

