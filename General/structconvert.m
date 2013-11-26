function s = structconvert(s,template)
%STRUCTCONVERT convert struct array to template struct in order and fields
%
%  S = STRUCTCONVERT(S,TEMPLATE)
%
% 2011, Alexander Heimel
%
if isempty(s)
    s = template([]);
end

flds = fields(template);
for f = flds'
    if ~isfield(s,f{1})
        for i = 1:length(s)
            s(i).(f{1}) = template.(f{1});
        end
        
    end
end
s = orderfields(s,template);