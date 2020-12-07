function [params,values] = varied_parameters( script )
%VARIED_PARAMETERS returns which parameters have been varied in a script
%
% 2012-2020, Alexander Heimel
%

params = {};
values = {};

possible_params = {'contrast','angle','sFrequency','tFrequency','sPhaseShift','size','typenumber','figdirection','gnddirection','background','location','duration','filename'};

ss = get(script);
if isempty(ss)
    return
end

sss = [];
for i = 1:length(ss)
    sss = [sss getparameters(ss{i})];
end

for i = 1:length(possible_params)
    if ~isfield(sss,possible_params{i})
        continue
    end
    vals =  [sss(:).(possible_params{i})];
    vals = vals(~isnan(vals));
    vals = uniq(sort(vals));
    if isfield(sss,possible_params{i}) && length( vals) > 1
        params{end+1} = possible_params{i};
        values{end+1} = vals;
    end
end

params{end+1} = 'stimnumber';
values{end+1} = 1:length(ss); % 1 to number of stimuli
