function cells = sort_with_wpca(orgcells,record, verbose)
%SORT_WITH_WPCA
%
%   CELLS = SORT_WITH_WPCA( ORGCELLS, RECORD )
%
% 2015, Mehran Ahmadlou, Alexander Heimel
%

if nargin<3 || isempty(verbose)
    verbose = true;
end

orgcells = pool_cells( orgcells );

% need to loop over channels, i.e. loop over cells
cells = [];
count = 1;
for ch=1:length(orgcells)
    [clusters,n_clusters] = spike_sort_wpca(orgcells(ch),record,verbose);
    for c = 1:n_clusters
        if count==1
            cells = orgcells(ch);
        else
            cells(count) = orgcells(ch); %#ok<AGROW>
        end
        ind = find(clusters==c);
        cells(count).data = orgcells(ch).data(ind);
        cells(count).ind_spike = ind;
        cells(count).spikes = orgcells(ch).spikes(ind,:);
        cells(count).wave = mean(cells(count).spikes,1);
        cells(count).std = std(cells(count).spikes,1);
        flds = fieldnames(orgcells(1));
        spike_fields = flds(strncmp('spike_',flds,6));
        for field = spike_fields(:)'
            cells(count).(field{1}) = orgcells(ch).(field{1})(ind); 
        end
        count = count + 1;
    end
end




