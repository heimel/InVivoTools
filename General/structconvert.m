function [s,changed] = structconvert(s,template)
%STRUCTCONVERT convert struct array to template struct in order and fields
%
%  [S,CHANGED]= STRUCTCONVERT(S,TEMPLATE)
%
% 2011-2014, Alexander Heimel
%
changed = false;

if isempty(template)
    return
end

if isempty(s)
    s = template([]);
    changed = true;
end

flds = fieldnames(template);
for f = flds'
    if ~isfield(s,f{1})
        changed = true;
        for i = 1:length(s)
            temp = template.(f{1});
            s(i).(f{1}) = temp([]);
        end
    end
end
s = rmfields(s, setdiff(fieldnames(s),flds)); % remove fields that are not in the template

[s,perm] = orderfields(s,template);
if ~all( perm==(1:length(perm))' )
    changed = changed | true;
end
