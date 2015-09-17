function plot_spike_isi( isi, record )
%PLOTS_SPIKE_ISI plot isis obtained with get_spike_interval
%
% 2013-2015, Alexander Heimel
%

if isempty(isi)
    return
end

if nargin<2
    record.test = '';
    record.date = '';
end

params = ecprocessparams(record);

xl = [-0.05 0.05];
x = xl(1):0.001:xl(2);
if isstruct(isi)
    channels2analyze = get_channels2analyze( record );
    if isempty(channels2analyze) % then take all
        channels2analyze = unique( [isi.channel]);
    end
    ind = logical(flatten(cellfun(@(x) ismember(x(1),channels2analyze)&&ismember(x(2),channels2analyze),{isi.channel},'UniformOutput',false)));
    isi = isi(ind);
    
    chan = unique( [isi.channel]);
    if isempty(chan)
        return
    end
    for ch = chan
        isi_on_channel = isi(logical(flatten(cellfun(@(x) x(1)==ch&x(2)==ch,{isi.channel},'UniformOutput',false))));
        figure('Name',['Spike intervals: ' record.test ',' record.date ',channel=' num2str(ch)] ,'Numbertitle','off');
        indices = unique([isi_on_channel.pair]);
        n_cells = length(indices);
        for i=1:length(isi_on_channel)
            c1 = find(indices==isi_on_channel(i).pair(1));
            c2 = find(indices==isi_on_channel(i).pair(2));
            subplot(n_cells,n_cells,(c1-1)*n_cells+c2);
            hist(isi_on_channel(i).data,x);
            xlim(xl);
        end
    end
    
else % deprecated way from before 2014-04-04
    n_cells = size(isi,1);
    
    if n_cells~=length(record.measures)
        errormsg('Number of cells in ISI is not equal to number of cells in measures. Recompute?');
        return
    end
    if n_cells>15
        logmsg('Too many cells, I am too lazy to plot them.');
        return
    end
    
    figure('Name',['Spike intervals: ' record.test ',' record.date] ,'Numbertitle','off');
    colors = params.cell_colors;
    
    for c1=1:n_cells
        for c2=1:c1
            subplot(n_cells,n_cells,(c1-1)*n_cells+c2);
            hist(isi{c1,c2},x);
            xlim(xl);
            if c1==n_cells
                xlabel(num2str(record.measures(c2).index));
            end
            if c2==1
                ylabel(num2str(record.measures(c1).index));
            end
            
        end
    end
    
end
