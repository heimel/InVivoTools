function isi = get_spike_interval(allcells, isi_old)
%GET_SPIKE_INTERVAL gets all interspike intervals
%
% ISI = GET_SPIKE_INTERVAL( CELLS, ISI_OLD )
%      ISI_OLD is old ISI to concatenate
%
% 2013-2014, Alexander Heimel
%


if nargin<2
    isi_old = [];
end

if isempty(allcells)
    isi = isi_old;
    return
end

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
 
if iscell(isi_old) % no idea why this would be necessary, 2014-04-05
    isi_old = [];
end

i = 1;
while i<length(isi_old)
    if ~isfield(isi_old,'channel') || any(ismember(isi_old(i).channel,chans))
        isi_old(i) = [];
    else
        i = i+1;
    end
end
isi = [isi_old isi];
