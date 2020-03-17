function record = wc_add_freezing_ind(record, verbose)
%WC_ADD_FREEZING_IND adds boolean list with frames in which freezing occurred
%
% 2020, Alexander Heimel

record.measures.ind_freeze = [];
record.measures.ind_freezestart = [];

if ~isfield(record.measures,'frametimes')
    return
end

t = record.measures.frametimes;
[~,freezetimes] = wc_get_freezetimes(record);
ind_freeze = [];
for i = 1:size(freezetimes,1)
    ind_freeze = [ind_freeze; find(t>=freezetimes(i,1) & t<=freezetimes(i,2))]; %#ok<AGROW>
end
record.measures.ind_freeze = ind_freeze;
if ~isempty(ind_freeze)
    record.measures.ind_freezestart =...
        ind_freeze( find(~isnan(record.measures.azimuth_trajectory(record.measures.ind_freeze)),1,'first'));
end