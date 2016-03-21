function plot_shapes_features( cells, record )
%PLOTS_SHAPES_FEATURES plot spikes shapes
%
% 2016, Alexander Heimel
%

if nargin<2
    record.test = '';
    record.date = '';
end


if isempty(cells)
    return
end

params = ecprocessparams(record);

if isfield(cells,'channel')
    channels = get_channels2analyze( record );
    if isempty(channels)
        channels = uniq(sort([cells.channel]));
    end
else
    channels = 1;
end

allcells = cells;

if ~isfield(cells,'spikes') 
    logmsg('No spikes saved.');
    return
end


for ch=channels
    if isfield(allcells,'channel')
        cells = allcells( [allcells.channel]==ch);
    end
    if isempty(cells)
        continue
    end
    
    
    n_cells = length(cells);
    % plot clusters
    figure('Name',['Spike shapes: ' record.test ', ' record.date ', channel=' num2str(ch) ] ,'Numbertitle','off');
    p = get(gcf,'position');
    p(4) = p(4)/2;
    set(gcf,'position',p);
    hold on
    colors = params.cell_colors;
    n_colors = length(colors);
    
    for c=1:n_cells
        n_spikes = size(cells(c).spikes,1);
        if n_spikes==0
            continue
        end
        stp = ceil(size(cells(c).spikes,1)/params.plot_spike_shapes_max_spikes);
        clr = colors( mod(c-1,n_colors)+1);
        ind = 1:stp:n_spikes;
        t = repmat( 1:size(cells(c).spikes,2),length(ind),1);
        %        [dum,trig_ind]=min(cells(c).spikes(ind,:),[],2);
        subplot(1,3,1);
        hold on
        plot(t',cells(c).spikes(ind,:)',clr);
        subplot(1,3,2);
        hold on
        %    plot(t'-repmat(trig_ind,1,size(cells(c).spikes,2))',cells(c).spikes(ind,:)',clr);
        if isfield(cells,'spike_prepeak_ind')
            plot(t'-repmat(cells(c).spike_prepeak_ind(ind),1,size(cells(c).spikes,2))',cells(c).spikes(ind,:)',clr);
            set(gca,'yticklabel',[]);
        end
        subplot(1,3,3);
        hold on
        %    plot(t'-repmat(trig_ind,1,size(cells(c).spikes,2))',cells(c).spikes(ind,:)',clr);
        if isfield(cells,'spike_trough_ind')
            plot(t'-repmat(cells(c).spike_trough_ind(ind),1,size(cells(c).spikes,2))',cells(c).spikes(ind,:)',clr);
            set(gca,'yticklabel',[]);
        end
    end
    for i=1:3
        subplot(1,3,i);
        c = get(gca,'children');
        set(gca,'children',c(randperm(length(c))))
        xlabel('Samples');
        
    end
    for c=1:n_cells
        subplot(1,3,1);
        plot(1:length(cells(c).wave),cells(c).wave,'w','linewidth',4)
        plot(1:length(cells(c).wave),cells(c).wave,colors( mod(c-1,n_colors)+1),'linewidth',3)
        subplot(1,3,2);
        [dum,trig_ind]=max(cells(c).wave);
        plot((1:length(cells(c).wave))-trig_ind,cells(c).wave,'w','linewidth',4)
        plot((1:length(cells(c).wave))-trig_ind,cells(c).wave,colors( mod(c-1,n_colors)+1),'linewidth',3)
        subplot(1,3,3);
        [dum,trig_ind]=min(cells(c).wave);
        plot((1:length(cells(c).wave))-trig_ind,cells(c).wave,'w','linewidth',4)
        plot((1:length(cells(c).wave))-trig_ind,cells(c).wave,colors( mod(c-1,n_colors)+1),'linewidth',3)
    end
    
    
    
    
end % channel ch





function show_cluster_overlap( record, channel)

params = ecprocessparams(record);

% cluster figure
axis off
report_overlap = params.cluster_overlap_threshold ;

if isfield(record.measures,'channel')
    measures = record.measures( [record.measures.channel]==channel);
else
    measures = record.measures;
end

if ~isfield(measures,'clust')
    return
end

n_cells = length(measures);

suggest_resort = false;

y = printtext('Overlapping clusters:');
multiunits = [];
for c1=1:n_cells
    if ~measures(c1).contains_data
        continue
    end
    for c2=(c1+1):n_cells
        if ~measures(c2).contains_data
            continue
        end
        
        if measures(c1).clust(c2)>report_overlap
            multiunits = [multiunits c1 c2];
            
            suggest_resort = true;
            y=printtext([ num2str(c1) ' and ' num2str(c2) ],y);
        end
    end
end
multiunits = uniq(sort(multiunits));
singleunits = setdiff(find([measures.contains_data]),multiunits);

if ~isempty(singleunits)
    logmsg(['Isolated single units: ' mat2str(singleunits)]);
else
    logmsg(['No well isolated single units']);
end

if 0 && isfield(measures,'clust')
    fh = figure('Name',[record.test ': Cluster overlap'],...
        'numbertitle','off',...
        'Position',[100 100 500 500]);
    cnames = {};
    clust = zeros(n_cells,n_cells);
    for i=1:n_cells
        cnm = ['Cell ',num2str(i)];
        cnames = [cnames,cnm];
        clust(i,:) = measures(i).clust;
    end;
    th = uitable('Data',clust,'ColumnName',cnames,'RowName',cnames,...
        'Parent',fh,'Position',[50 50 400 400]);
end

if isfield(measures,'p_multiunit')
    for c=1:n_cells
        logmsg([num2str(measures(c).index,'%3d') ' P(multiunit) = ' num2str(measures(c).p_multiunit,2)]);
        logmsg([num2str(measures(c).index,'%3d') ' P(subunit)   = ' num2str(measures(c).p_subunit,2)]);
    end
end


if suggest_resort
    logmsg(['Occasional cluster overlap larger than ' num2str(report_overlap) '. Consider resorting.']);
end
