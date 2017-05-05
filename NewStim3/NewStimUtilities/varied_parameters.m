function [params,values] = varied_parameters( script )
%VARIED_PARAMETERS returns which parameters have been varied in a script
%
% 2012, Alexander Heimel
%

params = {};
values = {};

possible_params = {'contrast','angle','sFrequency','tFrequency','sPhaseShift','size','typenumber','figdirection','gnddirection','background','location','filename'};

ss = get(script);
for i = 1:length(ss)
    sss(i) = getparameters(ss{i});
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