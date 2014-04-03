function isi = get_spike_interval(allcells)
%GET_SPIKE_INTERVAL gets all interspike intervals
%
% ISI = GET_SPIKE_INTERVAL( CELLS )
%
% 2013, Alexander Heimel
%

max_spikes = 2000; 
max_interval = 0.05;

chans = unique([allcells.channel]);

counter = 1;
for ch=chans % only do per channel for the moment.
    ind = find( [allcells.channel]==ch);
    cells = allcells(ind);
    n_cells = length(cells);
    for c1=1:n_cells
        for c2=1:c1
             spikes1 = repmat( cells(c1).data(1:min(end,max_spikes))',...
                length(cells(c2).data(1:min(end,max_spikes))),1);
            spikes2 = repmat( cells(c2).data(1:min(end,max_spikes)),...
                1,length(cells(c1).data(1:min(end,max_spikes))));
            intervals = flatten(spikes2-spikes1);
            intervals(intervals==0) = [];
            isi(counter).pair(1) = cells(c1).index;
            isi(counter).channel(1) = cells(c1).channel; 
            isi(counter).pair(2) = cells(c2).index;
            isi(counter).channel(2) = cells(c2).channel; 
            isi(counter).data = intervals(abs(intervals)<max_interval);
            counter = counter+1;
        end
    end
end
 
