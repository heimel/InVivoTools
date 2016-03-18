function cells = get_spike_features( cells, record )
%GET_SPIKE_FEATURES computes Niell & Stryker 2008 spike features
%
%    late_slope is slope of the waveform 0.5 ms after initial trough
%
%
% 2012-2015, Mehran Ahmadlou & Alexander Heimel
%

if nargin<2
    record = [];
end

params = ecprocessparams(record);

for c=1:length(cells)
    spikes = cells(c).spikes;
    
    if isempty(spikes)
        cells(c).spike_amplitude = [];
        cells(c).spike_trough2peak_time = [];
        cells(c).spike_peak_trough_ratio = [];
        cells(c).spike_prepeak_trough_ratio = [];
        cells(c).spike_lateslope = [];
        cells(c).spike_peak_height = [];
        cells(c).spike_trough_depth = [];
        cells(c).spike_prepeak_ind = [];
        cells(c).spike_trough_ind = [];
        cells(c).spike_peak_ind = [];
        continue
    end
    
    n_spikes = size(spikes,1);
    
    prepeak_height= nan(n_spikes,1);
    peak_height= nan(n_spikes,1);
    trough_depth = nan(n_spikes,1);
    
    [dum1,trough_ind ] = min(spikes,[],2);
    [dum2,peak_ind ] = max(spikes,[],2);
    
    trigger_ind = [];
    [postrigger,postrigger_ind]=max(min(spikes,[],1));
    if postrigger>0
        trigger_ind = postrigger_ind;
    end
    [negtrigger,negtrigger_ind]=min(max(spikes,[],1));
    if ~isempty(negtrigger) && negtrigger<0 && isempty(trigger_ind)
        trigger_ind = negtrigger_ind;
    end
    if isfield(params,'sort_trigger_ind') && isempty(trigger_ind)
        trigger_ind = params.sort_trigger_ind;
    end
    
    triggered_trough = (spikes(:,trigger_ind)<0)';
    
    [dum3,rel_trough_ind] = min(spikes(~triggered_trough,trigger_ind:end),[],2);
    trough_ind(~triggered_trough) = trigger_ind-1+rel_trough_ind;
    
    
    [dum3,rel_trough_ind_short] = min(spikes(triggered_trough,max(1,trigger_ind-2):min(end,trigger_ind+5)),[],2);
    trough_ind(triggered_trough) = max(1,trigger_ind-2)-1+rel_trough_ind_short;
    
    for i=1:n_spikes
        trough_depth(i) = spikes(i,trough_ind(i));
    end
    
    [dum4,rel_prepeak_ind] = max(spikes(triggered_trough,1:trigger_ind),[],2);
    prepeak_ind = [];
    prepeak_ind(triggered_trough) = rel_prepeak_ind;
    prepeak_ind(~triggered_trough) = trigger_ind;
    for i=1:n_spikes
        prepeak_height(i) = spikes(i,prepeak_ind(i));
    end
    
    [dum5,rel_peak_ind] = max(spikes(triggered_trough,trigger_ind:end),[],2);
    if any(triggered_trough)
        peak_ind(triggered_trough) = trigger_ind-1+rel_peak_ind;
    end
    
    ind = find(~triggered_trough);
    rel_peak_ind = nan(length(ind),1);
    for i=1:length(ind)
        [dum6,rel_peak_ind(i)] = max(spikes(ind(i),trough_ind(ind(i)):end),[],2);
    end
    if any(~triggered_trough)
        peak_ind(~triggered_trough) = trough_ind(~triggered_trough)-1+rel_peak_ind;
    end
    for i=1:n_spikes
        peak_height(i) = spikes(i,peak_ind(i));
    end
    
    
    late1_ind = trigger_ind + round( 0.4/1000/ cells(c).sample_interval);
    late2_ind = trigger_ind + round( 0.6/1000/ cells(c).sample_interval);
    lateslope = nan(size(peak_height));
    if late2_ind >= size(spikes,2)
        warning('GET_SPIKE_FEATURES:TOO_SHORT','Recorded spikes too short for late slope.');
        warning('off','GET_SPIKE_FEATURES:TOO_SHORT');
    else
        for i = 1:n_spikes
            lateslope(i) = ...
                (spikes(i,late2_ind)-spikes(i,late1_ind)) / ...
                ((late2_ind-late1_ind)*cells(c).sample_interval);
        end
    end
    
    cells(c).spike_amplitude = max(prepeak_height,peak_height) - trough_depth;
    cells(c).spike_trough2peak_time = (peak_ind-trough_ind)*cells(c).sample_interval*1000; %ms
    cells(c).spike_peak_trough_ratio = -peak_height ./ trough_depth;
    cells(c).spike_prepeak_trough_ratio = -prepeak_height ./ trough_depth;
    cells(c).spike_lateslope = lateslope / 1000;
    cells(c).spike_peak_height = peak_height;
    cells(c).spike_trough_depth = trough_depth;
    cells(c).spike_prepeak_ind = prepeak_ind'; 
    cells(c).spike_trough_ind = trough_ind; 
    cells(c).spike_peak_ind = peak_ind; 
end % c
