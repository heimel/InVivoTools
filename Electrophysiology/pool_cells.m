function cells = pool_cells( orgcells )
%POOL_CELLS pools cells on each channel into single cell
%
% 2015, Alexander Heimel

cells = [];
if isempty(orgcells)
    return
end

channels = unique([orgcells.channel]);
for ch = channels
    ind = find([orgcells.channel] == ch );
    if isempty(cells)
        cells = orgcells(ind(1));
    else
        cells(end+1) = orgcells(ind(1)); %#ok<AGROW>
    end
    flds = fieldnames(cells(end));
    spike_fields = flds(strncmp('spike_',flds,6));
    for i=2:length(ind)
        cells(end).data = [cells(end).data; orgcells(ind(i)).data];
        cells(end).spikes = [cells(end).spikes; orgcells(ind(i)).spikes];
        cells(end).ind_spike = [cells(end).ind_spike; orgcells(ind(i)).ind_spike];
        cells(end).wave = [];
        cells(end).std = [];
%         cells(end).snr = [];
        for field = spike_fields(:)'
            cells(end).(field{1}) = [cells(end).(field{1}); orgcells(ind(i)).(field{1})];
        end
    end
end