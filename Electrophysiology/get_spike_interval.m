function isi = get_spike_interval(cells)
%GET_SPIKE_INTERVAL gets all interspike intervals
%
% ISI = GET_SPIKE_INTERVAL( CELLS )
%
% 2013, Alexander Heimel
%

max_spikes = 2000;
max_interval = 0.05;
n_cells = length(cells);
for c1=1:n_cells
    for c2=1:c1
        spikes1 = repmat( cells(c1).data(1:min(end,max_spikes))',...
            length(cells(c2).data(1:min(end,max_spikes))),1); 
        spikes2 = repmat( cells(c2).data(1:min(end,max_spikes)),...
            1,length(cells(c1).data(1:min(end,max_spikes)))); 
        intervals = flatten(spikes2-spikes1);
        intervals(intervals==0) = [];
        isi{c1,c2} = intervals(abs(intervals)<max_interval);
    end
end
 
