function plot_spike_isi( isi, record )
%PLOTS_SPIKE_ISI plot isis obtained with get_spike_interval
%
% 2013, Alexander Heimel
%

if nargin<2
    record.test = '';
    record.date = '';
end

params = ecprocessparams(record);

n_cells = size(isi,1);

if n_cells~=length(record.measures)
    errormsg('Number of cells in ISI is not equal to number of cells in measures. Recompute?');
    return
end

if n_cells>15
    disp('PLOT_SPIKE_ISI: Too many cells, I am too lazy to plot them.');
    return
end

figure('Name',['Spike intervals: ' record.test ',' record.date] ,'Numbertitle','off');
colors = params.cell_colors;
n_colors = length(colors);

xl = [-0.05 0.05];
x = xl(1):0.001:xl(2);
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
    