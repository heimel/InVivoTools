function [IDX,NumClust] = spike_sort_wpca(cll1,record,verbose)
%
%
% 2013-2015, Mehran Ahmadlou, Alexander Heimel
%

if nargin<2  
    record = [];
end
if nargin<3 || isempty(verbose)
    verbose = true;
end

params = ecprocessparams(record);

NumClust = params.max_spike_clusters;

if length(cll1(1).data)<10% cant sort with less than 10 spikes
    logmsg('Fewer than 10 spikes. Not sorting channel');
    NumClust = 1;
end

if NumClust == 1
    IDX = ones(size(cll1.data));
    return
end

range_peak_trough_ratio = range(cll1.spike_peak_trough_ratio);
if range_peak_trough_ratio==0
    range_peak_trough_ratio = 1;
end
range_prepeak_trough_ratio = range(cll1.spike_prepeak_trough_ratio);
if range_prepeak_trough_ratio==0
    range_prepeak_trough_ratio = 1;
end
range_trough2peak_time = range(cll1.spike_trough2peak_time);
if range_trough2peak_time == 0 
    range_trough2peak_time = 1;
end
range_spike_lateslope = range(cll1.spike_lateslope);
if range_spike_lateslope == 0 
    range_spike_lateslope = 1;
end

XX=[cll1.spike_peak_height,...
    cll1.spike_trough_depth,... 
    cll1.spike_amplitude,... 
     cll1.spike_lateslope/range_spike_lateslope,...
     cll1.spike_prepeak_trough_ratio/range_prepeak_trough_ratio,...
     cll1.spike_trough2peak_time/range_trough2peak_time,...
     cll1.spike_peak_trough_ratio/range_peak_trough_ratio,...
     cll1.spike_lateslope
    ];


%[pc,score,latent,tsquare] = princomp(XX);
[pc,score,latent,tsquare] = pca(XX);

%[IDX,f1,f2,D] = kmeans(score(:,1:3),NumClust);
[IDX,f1,f2,D] = kmeans(score,NumClust);
%[IDX,f1,f2,D] = kmeans(XX,NumClust);

if verbose
    figure('Name',['Spike PCs: ' record.test ', ' record.date ', channel=' num2str(cll1.channel) ] ,'Numbertitle','off');
    for f1=1:2
        for f2=(f1+1):3
            subplot(2,2,(f2-2)*2+f1);
            xlabel(['PC ' num2str(f1)]);
            ylabel(['PC ' num2str(f2)]);
            hold on
            clr = params.cell_colors ;
            for c=1:NumClust
                plot(score(IDX==c,f1),score(IDX==c,f2),['.' clr(c)]);
                
            end
        end
    end
end
return

