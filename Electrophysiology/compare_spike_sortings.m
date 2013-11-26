function cells1 = compare_spike_sortings(cells1,cells2)
%COMPARE_SPIKES_SORTINGS compared sorted spikes
%
% 2013, Alexander Heimel
%

neuron1 = sort_spikes( cells1 );
neuron2 = sort_spikes( cells2 );

if length(neuron1)~=length(neuron2)
    disp('COMPARE_SPIKE_SORTING: Unequal numbers of spikes for the two sortings');
end

n_cells1 = length(cells1);
n_cells2 = length(cells2);

mapping1to2 = zeros(n_cells1,n_cells2);
for c1=1:n_cells1
    for c2=1:n_cells2
        ind1 = (neuron1==c1);
        mapping1to2(c1,c2) = sum(neuron2(ind1)==c2);
    end
end

%fig = figure();
%h=uitable(fig,'Data',mapping1to2,'Units','normalized','Position',[0 0 1 1]);

[max_common_spikes,ind_max_mapping] = max(mapping1to2,[],2);
p_multiunit = 1-max_common_spikes./sum(mapping1to2,2); % subclusters
n_spikes2 = sum(mapping1to2,1);
p_subunit = 1-max_common_spikes./n_spikes2(1,ind_max_mapping)'; % part of a larger cluster

for c=1:n_cells1
    cells1(c).p_multiunit = p_multiunit(c);
    cells1(c).p_subunit = p_subunit(c);
end



function neuron = sort_spikes( cells )
time = [];
neuron = [];
for c = 1:length(cells)
    time(end+1:end+length(cells(c).data)) = cells(c).data;
    neuron(end+1:end+length(cells(c).data)) = c;
end
[~,ind] = sort(time);
neuron = neuron(ind);

