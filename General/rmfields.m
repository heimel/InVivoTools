function s = rmfields(s,f)
%RMFIELDS removes one or more fields from structure
%
% S = RMFIELDS(S, F)
%       S is struct, and F is a cell list of fieldnames to remove from S
%
% 2014, Alexander Heimel
%

for i=1:length(f)
    if isfield(s,f{i})
        s = rmfield(s,f{i});
    end
end
