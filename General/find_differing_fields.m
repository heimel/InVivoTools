function differing_fields = find_differing_fields(S)
%FIND_DIFFERING_FIELDS Find fields that differ across struct array elements
%
% differing_fields = find_differing_fields(S)
%
% Input:
%   S : struct array
%
% Output:
%   differing_fields : cell array of field names for which at least
%                      one struct element differs from the others
%
% 2026, ChatGPT, Alexander Heimel

% Handle empty input
if isempty(S)
    differing_fields = {};
    return;
end

fields = fieldnames(S);
differing_fields = {};

for iField = 1:numel(fields)
    field = fields{iField};

    % Take first value as reference
    ref = S(1).(field);

    differs = false;

    for i = 2:numel(S)
        val = S(i).(field);

        % Use isequaln so that NaNs compare equal
        if ~isequaln(ref, val)
            differs = true;
            break;
        end
    end

    if differs
        differing_fields{end+1} = field; %#ok<AGROW>
    end
end
end