function [c,flds] = structdiff(a,b,verbose)
%STRUCTDIFF compares structure fields and their contents
%
% C = STRUCTDIFF( A, B )
% C = STRUCTDIFF( A, B, VERBOSE )
% [C,FLDS] = STRUCTDIFF( A, B, VERBOSE )
%
%    returns C=1 if all fields of A and B are identical
%    FLDS contains all fieldnames which differ
%
% Steve VanHooser, Alexander Heimel
%

if nargin<3
    verbose = false;
end
if nargout == 2
    breakout = false;
else
    breakout = true;
end
flds = {};

c = 1;
fna = fieldnames(a);
fnb = fieldnames(b);

for i=1:length(fna)
    [j,jj,ii]=intersect(fna{i},fnb);
    if ~isempty(j),
        if ~all(getfield(a,fna{i})==getfield(b,fnb{ii}))
            flds{end+1} = fna{i};
            if verbose
                disp(['Fields ''' fna{i} ''' differ.']);
            end
            c = 0;
            if breakout
                break;
            end
        end;
    else
        c = 0;
        flds{end+1} = fna{i};
        if verbose
            disp(['Field name ''' fna{i} ''' not present in b.']);
        end
        if breakout
            break;
        end
    end;
end;

