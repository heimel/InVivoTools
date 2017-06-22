function [s,changed] = structconvert(s,template,remove_additional_fields)
%STRUCTCONVERT convert struct array to template struct in order and fields
%
%  [S,CHANGED]= STRUCTCONVERT(S,TEMPLATE,REMOVE_ADDITIONAL_FIELDS=true)
%
%  if REMOVE_ADDITIONAL_FIELDS==true, then remove fields that are not in the template
%
% 2011-2014, Alexander Heimel
%

if nargin<3 || isempty(remove_additional_fields)
    remove_additional_fields = true;
end

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

additional_fields = setdiff(fieldnames(s),flds);

if remove_additional_fields % remove fields that are not in the template
    s = rmfields(s, additional_fields);
else
    flds = [flds;additional_fields];
end

[s,perm] = orderfields(s,flds);
if ~all( perm==(1:length(perm))' )
    changed = changed | true;
end
