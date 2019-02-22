function P = getparameters(S)
%
%  Part of the NewStim package
%
%  P = GETPARAMETERS(S)
%
%  Returns the parameters of the stimscript S.
%
% 200X, Steve van Hooser
% 2017, Alexander Heimel

try
    parray = cellfun(@getparameters,get(S));
    for f = fieldnames(parray)'
        if all(isnumeric([parray.(f{1})]))
            P.(f{1}) = cat(1,parray.(f{1}));
        else
            P.(f{1}) = {parray.(f{1})};
        end
        try
            P.(f{1}) = unique(P.(f{1}));
        end
    end
catch
    P = [];
end
