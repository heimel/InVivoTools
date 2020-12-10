function [c,flds] = structdiff(a,b,verbose)
%STRUCTDIFF compares structure fields and their contents
%
% C = STRUCTDIFF( A, B )
% C = STRUCTDIFF( A, B, VERBOSE )
% [C,FLDS] = STRUCTDIFF( A, B, VERBOSE )
%
%    returns C=1 if all fields of A and B are identical, C=0 otherwise
%    FLDS contains all fieldnames which differ
%
% 200X, Steve VanHooser
% 200X-2018, Alexander Heimel

if nargin<3
    verbose = false;
end
if nargout == 2 || verbose
    breakout = false;
else
    breakout = true;
end
flds = {};

c = 1;

if (isempty(a) && ~isempty(b)) || (~isempty(a) && isempty(b))
    c = 0;
    return
end
    
fna = fieldnames(a);
fnb = fieldnames(b);

for i=1:length(fna)
    [j,jj,ii] = intersect(fna{i},fnb);
    if ~isempty(j)
        if isa(a.(fna{i}),'function_handle')
            if ~isa(b.(fnb{ii}),'function_handle') ...
                    || ~strcmp(func2str(a.(fna{i})),func2str(b.(fnb{ii})))
                c = 0;
                if verbose
                    disp(['Fields ''' fna{i} ''' differ.']);
                end
                if breakout
                    break
                end
            end
            continue
        end
        if ndims(a.(fna{i})) ~= ndims(b.(fnb{ii})) || ...
                any(size(a.(fna{i})) ~= size(b.(fnb{ii}))) || ...
                ~all(a.(fna{i})(:)==b.(fnb{ii})(:))
            flds{end+1} = fna{i};
            if verbose
                disp(['Fields ''' fna{i} ''' differ.']);
            end
            c = 0;
            if breakout
                break
            end
        end
    else
        c = 0;
        flds{end+1} = fna{i};
        if verbose
            disp(['Field name ''' fna{i} ''' not present in b.']);
        end
        if breakout
            break
        end
    end
end

