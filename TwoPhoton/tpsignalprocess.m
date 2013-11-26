function [processed_data, processed_t] = tpsignalprocess(params, data, t)
%  TPSIGNALPROCESS - processes two-photon data
%
%     [PROCESSED_DATA, PROCESSED_T] = TPSIGNALPROCESS(METHOD, DATA, T,
%     PARAMS)
%
%    PARAMS.filter.type = {'none','smooth'}
%                 .parameters = for smooth: averaging window length 
%                 .unit = {'s','#'} 
%    PARAMS.method is one of {'normalize','none','event_detection'}
%         normalize produces Delta F / F
%    PARAMS.peak_removal_percentile (percent) is threshold to remove peaks
%    PARAMS.artefact_diplevel (std) is threshold to marks
%    PARAMS.detrend is one of {true, false} and sets whether to detrend
%        individual data sections
%
% 2010, Alexander Heimel
%

if ischar(params)
    switch params
        case '?'
            % return possible methods
            processed_data = {'none','normalize','event_detection'};
            return
        otherwise
            error('TPSIGNALPROCESS:unknown_option','TPSIGNALPROCESS: Unknown option');
    end
end

if ~isfield(params,'method')
    params.method = 'none';
end


default = tpprocessparams( params.method );

sampletime = (t{1,1}(end) - t{1,1}(1)) / (length(t{1,1})-1);


% fill in params struct by default
for f = fields(default)'
    if ~isfield(params,f{1})
        params.(f{1}) = default.(f{1});
    end
end

%disp(['Signal processing method: ' params.method]);


% clip data into separate intervals when time gaps are large
if params.clip_data
    [data, t] = clip_data( data, t, params);
end

% filter (smoothen)
switch params.filter.type
    case 'none'
        % do nothing
    case 'smooth'
        switch params.filter.unit
            case '#'
                span = params.filter.parameters;
            case 's'
                span = ceil(params.filter.parameters /sampletime);
        end                
        if span>0
        for i = 1:numel(data)
            data{i} = smooth( data{i}, span );
        end
        end
end

% remove global dip artefacts
if params.artefact_removal
 [data, t] = remove_artefacts( data, t, params);
end

% remove peaks in unpeaked data (still present in raw data)
[unpeaked_data,unpeaked_t] = remove_peaks( data, t, params);

% detrend, mean is unchanged
if params.detrend
    for i=1:numel(data)
        md = nanmean(unpeaked_data{i});
        mt = nanmean(unpeaked_t{i});
        if sum(~isnan(unpeaked_data{i})) > 1
            rc = regress(unpeaked_data{i} - md,unpeaked_t{i}-mt);
        else
            rc = 0;
        end
        %  [unpeaked_d{i},trend] = mydetrend( unpeaked_data{i} );
        % data{i} = data{i} - trend;

        unpeaked_data{i} = unpeaked_data{i} - rc*(unpeaked_t{i}-mt);
        data{i} = data{i} - rc*(t{i}-mean(t{i}));
        
%         figure;plot(t{i},data{i},'k');hold on;
%         plot(unpeaked_t{i},unpeaked_data{i},'r');
%         pause
     end
end

%normalize
if params.normalize
    % normalize by dividing each cell's fluorescence by its temporal mean
    % and subtract 1 to produce \Delta F / F
    %
    % keep in mind that data kan be MxN cell array
    % (intervals,cells)
    for i=1:numel(data)
        m = nanmean( unpeaked_data{i} );
        data{i} = data{i} / m - 1;
        unpeaked_data{i} = unpeaked_data{i} / m - 1;
    end
end

% event detection
if params.detect_events
    [data, t] = detect_events( data, t, unpeaked_data, params, sampletime);
    if params.detect_events_group
        [data, t] = group_events(data, t, params);
    end
end

processed_data = data;
processed_t = t;

return
%%%


function [grouped_data, grouped_t] = group_events(data, t, params)

grouped_data = cell(size(data));
grouped_t = cell(size(t));
for i=1:size(data,1) % intervals
    % first get all event times
    all_event_times = [];
    for c=1:size(data,2)
        all_event_times = [all_event_times; t{i,c}];
    end
    if isempty(all_event_times)
        for c=1:size(data,2) % cells
            grouped_data{i,c} = [];
            grouped_t{i,c} = [];
        end
        continue
    end
    
    grouping_method = 'max_spike_interval';
    %grouping_method = 'peaks_in_mean_normal_signal'
    switch grouping_method
        case 'max_spike_interval'
            all_event_times = sort(all_event_times);
            % bin events by finding gaps in sequential events
            diff_all_event_times = diff(all_event_times);
            event_group_bins = [all_event_times(1); ...
                all_event_times( find(diff_all_event_times> params.detect_events_group_width)+1); all_event_times(end)];
            n_event_groups = length( event_group_bins) - 1;
%        case 'peaks_in_mean_normal_signal'
 %           raw_peaks = []
 %           for c=1:size(data,2) % cells
  %              mean_signal = data{i,c}
   %         end
    end
    
    
    % by taking only one peak for each cell, gaps call fall in the
    % grouping with are larger than detect_events_group_width
    gaps_too_big = true;

    while gaps_too_big
        
        
        % now find all spikes for each event group
        for c=1:size(data,2) % cells
            % set default data to zero, and time to NaN
            grouped_data{i,c} = zeros(n_event_groups,1);
            grouped_t{i,c} = NaN * zeros(n_event_groups,1);
            for e=1:n_event_groups
                % find *first* cell peak within event interval
                ind = find( t{i,c}>=event_group_bins(e) & t{i,c}<event_group_bins(e+1), 1);
                if ~isempty(ind) % i.e. there is an event for this cell
                    grouped_data{i,c}(e) = data{i,c}(ind);
                    grouped_t{i,c}(e) = t{i,c}(ind);
                end
            end
        end % cell c
        
        % now check no spike interval became to big in some occasions
        gaps_too_big = false;
        for event = 1:n_event_groups
            celltimes = zeros(1,size(data,2));
            celldata = zeros(1,size(data,2));
            for c=1:size(data,2)
                celltimes(c) = grouped_t{i,c}(event);
                celldata(c) = grouped_data{i,c}(event);
            end
            celltimes = sort(celltimes);
            dcelltimes = diff(celltimes);
            ind = find(dcelltimes >params.detect_events_group_width);
            if ~isempty( ind)
                gaps_too_big = true;
                event_group_bins = [event_group_bins ; celltimes(ind+1)'];
            end
        end
        if gaps_too_big
            event_group_bins = sort(event_group_bins);
        end
    end  % while gaps_too_big
    

    % remove all groups with fewer than params.detect_events_group_minimal_cell_number
    if params.detect_events_group_minimum_cell_number < 1
        min_cells = params.detect_events_group_minimum_cell_number * size(t,2); % if fraction, convert to number
    else
        min_cells = params.detect_events_group_minimum_cell_number;
    end
    
    ind = find(sum(~isnan([grouped_t{i,:}]),2) >= min_cells); % events with at least minimal cell number
    for c=1:size(data,2) % cells
        grouped_data{i,c} = grouped_data{i,c}(ind);
        grouped_t{i,c} = grouped_t{i,c}(ind);
    end
end % interval i



return




function [event_data, event_t] = detect_events(data, t,unpeaked_data, params, sampletime)
warning('off','signal:findpeaks:largeMinPeakHeight');
warning('off','signal:findpeaks:noPeaks');

event_t = cell(size(data));
event_data = cell(size(data));
event_threshold = zeros(size(data));
for i=1:size(data,1)
    for c=1:size(data,2)
        % set event threshold for each cell and each interval
        event_threshold(i,c) = params.detect_events_threshold * ...
            nanstd(unpeaked_data{i,c}) ;

        % detect peaks above threshold for each cell
        minpeakd = ceil(min([params.detect_events_minpeakdistance / sampletime length(data{i,c})-1]));

        try
            if params.findpeaks_fast 
                [pks,locs] = findpeaks_fast([-Inf; data{i,c}],...
                    'minpeakheight',event_threshold(i,c),...;
                    'minpeakdistance',minpeakd);
            else
                [pks,locs] = findpeaks([-Inf; data{i,c}],...
                    'minpeakheight',event_threshold(i,c),...;
                    'minpeakdistance',minpeakd);
            end
        catch
            disp('TPSIGNALPROCESS: error in findpeaks');
            pks = [];
            locs = [];
        end
        
        % the addition of -Inf and the decrement of locs is to bypass a
        % bug in FINDPEAKS
        locs = locs-1; % shift to point to right index

        % for each peak compute event onset time
        event_t{i,c} = []; %zeros( length(locs),1);
        event_data{i,c} = []; %zeros( length(locs),1);
        peak_index = 1;
        for p = 1:length(locs)
            peak_amplitude = pks(p);
            peak_time = t{i,c}(locs(p));

            event_data{i,c}(peak_index,1) = peak_amplitude;
            switch params.detect_events_time
                case 'peak'
                    event_t{i,c}(peak_index,1) = peak_time;
                case 'onset'

                    ind = (find(t{i,c} > peak_time - params.detect_events_max_time_before_peak,1,'first') : ...
                        find(t{i,c} ==peak_time)); % everything from max_time before peak up to peak

                    % introduce data's derivative
                    ddata=diff(data{i,c}(ind));
                    ddata=smooth(ddata,max(1,length(ind)/10));

                    indhh = find(data{i,c}(ind(2:end-1)) < pks(p)/2,1,'last'); % halfheight position
                    if isempty(indhh)
                        % No real peak, still on down flank of previous peak...
                        continue
                    end


                    % fit threshold linear to derivative
                    [m,ind_minslope] = min(ddata(1:indhh)); % point of min slope
                    if params.detect_events_fit_slope == false || m>0 
                        % did not include part with negative slope
                        % or ignore derivative
                        [rc,offset]=fit_thresholdlinear(t{i,c}(ind(1:indhh))',data{i,c}(ind(1:indhh))');
                        onset_time = -offset / rc; % onset
                    else
                        ind_minslope = max( ceil( params.detect_events_margin/sampletime) ,ind_minslope); % stay away from left border
                        [temp,ind_maxslope] = max(ddata(ind_minslope:end-ceil(params.detect_events_margin/sampletime))); % point of maximum slope, starting to look from bottom up
                        ind_maxslope = ind_maxslope + ind_minslope-1;
                        [rc_d,offset_d]=fit_thresholdlinear(t{i,c}(ind(ind_minslope:ind_maxslope))',ddata(ind_minslope:ind_maxslope)');
                        % onset time is start of upward slope
                        onset_time = -offset_d / rc_d;
                    end
                    
                    % if incorrect, then just use date instead of slope
                    if onset_time>=peak_time
                        [rc,offset]=fit_thresholdlinear(t{i,c}(ind(1:indhh))',data{i,c}(ind(1:indhh))');
                        onset_time = -offset / rc; % onset
                    end
                    
                    % if not correct, then take last negative datasample as
                    % onset
                    if onset_time<= t{i,c}(ind(1)) || onset_time >= t{i,c}(ind(end))
                        last_negative_data_point = t{i,c}(ind( find(ddata<0,1,'last')  ));
                        if ~isempty(last_negative_data_point)
                            onset_time = last_negative_data_point;
                        end
                    end
                    
                    % if still not correct, then take last negative slope
                    % as onset
                    if onset_time<= t{i,c}(ind(1)) || onset_time >= t{i,c}(ind(end))
                        last_negative_slope = t{i,c}(ind( find(data{i,c}(ind)<0,1,'last')  ));
                        if ~isempty(last_negative_slope)
                            onset_time = last_negative_slope;
                        end
                    end
                                        
                    if onset_time<= t{i,c}(ind(1)) || onset_time >= t{i,c}(ind(end))
                        if process_params.output_show_figures
                            plot_event_individual_cell( data{i,c}(ind), t{i,c}(ind), onset_time,peak_time,peak_amplitude,event_threshold(i,c))
                        end
                        %   keyboard
                    end

                    event_t{i,c}(peak_index,1) = onset_time;
            end
            peak_index = peak_index + 1;
        end % peak number p
    end % cell number c
end % interval number i




function plot_event_individual_cell( data, t, onset_time,peak_time,peak_amplitude,threshold)
figure; hold on;
plot( t,data);
text(onset_time,data(findclosest(t,onset_time)),'v');
disp(['Onset time = ' num2str(onset_time)]);
text(peak_time,peak_amplitude,'V');
ax=axis;
ax(1) = min(ax(1),onset_time);
ax(3) = min(ax(3),0);
axis(ax);
plot([ax(1) ax(2)],[threshold threshold],'y');
return

 function [y,trend] = mydetrend(x)
 N = length(x);
 a  = [zeros(N,1) ones(N,1)];
 a((1:N),1) = (1:N)'/N;
 trend = a*(a\x);
 trend = trend - mean(trend);
 y = x - trend;

function [new_data, new_t] = clip_data( data, t, params)
n_cells = size(data,2);
n_intervals = size(data,1);


new_interval = 1;
for i = 1:n_intervals
    d = diff( t{i,1} );
    ind_breaks = [0; find(d(:)>=params.clip_data_max_gap); length(t{i,1})];
    for j = 1:length(ind_breaks)-1
        for c = 1:n_cells
            new_data{new_interval,c} = data{i,c}(ind_breaks(j)+1:ind_breaks(j+1)); %#ok<AGROW>
            new_t{new_interval,c} = t{i,c}(ind_breaks(j)+1:ind_breaks(j+1)); %#ok<AGROW>
        end
        new_interval = new_interval + 1;
    end
end



function [unpeaked_data,unpeaked_t] = remove_peaks( data, t, params)
% remove peaks in unpeaked data (still present in raw data)
% substitute linear interpolation between beginning and end of peaks

unpeaked_data = data;
unpeaked_t = t;
sample_t = (t{1}(end)-t{1}(1))/length(t{1});
removal_width =  fix(params.peak_removal_width/sample_t);
if ~isnan(params.peak_removal_percentile)
    for i = 1:numel(data)
        peaklevel = prctile(data{i},params.peak_removal_percentile);
        peak_ind = find( data{i} > peaklevel );
        %start_ind = max(1,peak_ind - round( 0.05 *length(data{i})));
        %stop_ind = min(length(data{i}),peak_ind + round( 0.05 *length(data{i})));
        start_ind = max(1,peak_ind - removal_width);
        stop_ind = min(length(data{i}),peak_ind + removal_width);
        for j = 1:length(peak_ind)
                  unpeaked_data{i}(start_ind(j): stop_ind(j))  = nan;
                  unpeaked_t{i}(start_ind(j): stop_ind(j))  = nan;
                  
            %             if 1
%                 unpeaked_data{i}(start_ind(j): stop_ind(j)) = ...
%                     linspace(unpeaked_data{i}(start_ind(j)),...
%                     unpeaked_data{i}(stop_ind(j)),...
%                     stop_ind(j)-start_ind(j)+1);
%             else
%                 
%                 center_ind =  floor((start_ind(j)+stop_ind(j))/2);
%                 unpeaked_data{i}(start_ind(j): center_ind) = ...
%                     unpeaked_data{i}(start_ind(j));
%                 
%                 unpeaked_data{i}(center_ind:stop_ind(j)) = ...
%                     unpeaked_data{i}(stop_ind(j));
%             end
        end
       %figure;plot(t{i},data{i});hold on;plot(unpeaked_t{i},unpeaked_data{i},'r');
        
    end
end



function [new_data, new_t] = remove_artefacts( data, t, params)
% remove global dip artefacts
if ~params.artefact_removal
    new_data = data;
    new_t = t;
    return
end

new_interval = 1;
% create global signal
for i=1:size(data,1)
    raw_global = mean([data{i,:}],2);
    % select 'normal' points
    raw_mean = mean(raw_global);
    raw_std = std(raw_global);
    ind = find( (raw_global > raw_mean - 3*raw_std) &...
        (raw_global < raw_mean + 3*raw_std ));
    % set diplevel
    diplevel = mean(raw_global(ind)) - params.artefact_diplevel*std(raw_global(ind));
    % find dips
    dip_ind = find( raw_global<diplevel );
    % broaden dips
    if ~isempty(dip_ind)
        [a,b] = meshgrid((-30:30),dip_ind);
        dip_ind = a+b;
        dip_ind = max(1, dip_ind(:));
        dip_ind = min(length(raw_global), dip_ind(:));
        interval_ind = setdiff(1:length(raw_global),dip_ind(:));

        interval_starts = [1 find(diff(interval_ind)>1)+1];
        interval_ends = [interval_starts(2:end)-1 length(interval_ind)];
        interval_starts_ind = interval_ind(interval_starts);
        interval_ends_ind = interval_ind(interval_ends);
    else
        interval_starts_ind = 1;
        interval_ends_ind = length(raw_global);
    end

    for j = 1:length(interval_starts_ind)
        %plot( t{i,1}(interval_starts_ind(j):interval_ends_ind(j)),...
        %    raw_global(interval_starts_ind(j):interval_ends_ind(j)),'r-');
        if interval_ends_ind(j)- interval_starts_ind(j) > params.artefact_minimal_samplenumber
            for c = 1:size(data,2)
                new_data{new_interval,c} = data{i,c}(interval_starts_ind(j):interval_ends_ind(j)); %#ok<AGROW>
                new_t{new_interval,c} = t{i,c}(interval_starts_ind(j):interval_ends_ind(j)); %#ok<AGROW>
            end
            new_interval = new_interval + 1;
        end
    end

end
