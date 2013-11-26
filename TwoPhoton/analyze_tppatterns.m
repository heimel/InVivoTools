function [result,process_params] = analyze_tppatterns(method, data, t, listofcells, listofcellnames, params,process_params, timeint )
%ANALYZE_TPPATTERNS shell function called by analyzetpstack for pattern analysis
%
%  RESULT = ANALYZE_TPPATTERNS('?') returns possible analysis methods
%
%  RESULT = ANALYZE_TPPATTERNS(METHOD, PIXELARG )
%     PIXELARG is struct containing the fields:
%        listofcells: cell list of pixelindex vectors for each cell
%    listofcellnames: cell list of cell names
%               data: cell list of vectors containing response for all
%               frames
%                  t: cell list of vectors containing average frametimes
%
%
% example pixelarg =
%        listofcells: {[111x1 double]  [110x1 double]  [112x1 double]}
%    listofcellnames: {'cell 1 ref t00001'  'cell 2 ref t00001'  'cell 3 ref t00001'}
%               data: {[100x1 double]  [100x1 double]  [100x1 double]}
%                  t: {[100x1 double]  [100x1 double]  [100x1 double]}
%
% 2009-2011, Alexander Heimel
%

%data = spike_order(t);
%data = spike_time(t);

if nargin<8
    process_params = tpprocessparams('event_detection');
end


switch method
    case '?'
        result =  {'correlation','cluster','event_statistics'};
        return
    case 'correlation'
        result = correlation_analysis( data, t, listofcells, listofcellnames, params );
    case 'cluster'
        result = cluster_analysis( data, t, listofcells, listofcellnames, params);
    case 'event_statistics'
        result = event_statistics( data, t, listofcells, listofcellnames, params, process_params, timeint);
    otherwise
        warning(['ANALYZE_TPPATTERNS: method ' method ' is not implemented yet.']);
end


% results_tppatternanalysis( result, process_params );

return
end

function p = get_cellpositions( listofcells, params )
% returns cell positions struct array with fields x and y (line,pixel)
for c = 1:length(listofcells)
    [y,x]=ind2sub([params.lines_per_frame,params.pixels_per_line],listofcells{c});
    p(c).x = mean(x) * params.micron_per_pixel;
    p(c).y = mean(y) * params.micron_per_pixel;
end
end


function r = spike_order(t)
% returns spike_order
disp('spike order sorting is biased when a cell does not participate');
r = {};
for i = 1:size(t,1)
    dat = [t{i,:}];
    [y,sort_ind] = sort(dat,2);
    for c = 1:size(t,2)
        r{i,c} = sort_ind(:,c);
    end
end
end

function r = spike_time(t)
% returns spike_order
disp('spike order sorting is biased when a cell does not participate');
r = {};
for i = 1:size(t,1)
    dat = [t{i,:}];
    dat = dat - repmat(min(dat')',1,size(t,2));
    for c = 1:size(t,2)
        r{i,c} = dat(:,c);
    end
end
end

function result = event_statistics( data, t, listofcells, listofcellnames, params, process_params, timeint)
%disp('working on event statistics in analyze_tppatterns');
% analysis spatial patterns present in the data
% preferably using grouped event data
% number of samples per cell should be identical



result.participating_fraction = [];
result.covariance_xt = [];
result.covariance_yt = [];
result.amplitude_participating_cells = [];
%combine data

all_t = [];
all_data = [];


for i = 1:size(data,1) % intervals
    all_t = [all_t;t{i,:}]; % events x cells
    all_data = [all_data;data{i,:}];
end % interval i

result.participating_fraction =  sum(~isnan(all_t),2)/length(listofcells);
result.timestd = nanstd(all_t')' ;

non_events = find(isnan(all_t));
all_positive_data = all_data;
all_positive_data(non_events) = NaN;
result.amplitude_participating_cells = [ nanmean( all_positive_data')'];

result.event_type = characterize_event_type( result.participating_fraction, result.timestd, result.amplitude_participating_cells, process_params);
result.cortical_events = (result.event_type == 2);
result.retinal_events = (result.event_type == 1);
result.all_events = (result.cortical_events | result.retinal_events);
result.cellpositions = get_cellpositions( listofcells, params ); % i.e. cellposition is in micron!

% wave_analysis
result = wave_analysis( all_data, all_t,listofcells, listofcellnames, params, process_params, timeint, result);

edges = ( (-pi):2*pi/20:(pi));
if any(result.retinal_waves)
    x = histc( result.direction( result.retinal_waves) ,edges);
    y = histc( result.shuffled_direction( result.shuffled_retinal_events)  ,edges);
    if size(x,1) < size(x,2), x = x';  end
    if size(y,1) < size(y,2), y = y';  end
    x = x(1:end-1);
    y = y(1:end-1);
    result.network_retinal_wave_direction_chi2_p = chi2class( [x y]);
else
    result.network_retinal_wave_direction_chi2_p = NaN;
end
if any(result.cortical_waves)
    x = histc( result.direction( result.cortical_waves) ,edges);
    y = histc( result.shuffled_direction( result.shuffled_cortical_events)  ,edges);
    if size(x,1) < size(x,2), x = x';  end
    if size(y,1) < size(y,2), y = y';  end
    x = x(1:end-1);
    y = y(1:end-1);
    result.network_cortical_wave_direction_chi2_p = chi2class( [x y]);
else
    result.network_cortical_wave_direction_chi2_p = NaN;
end

   

% for calculating presence of preferred direction
n_rose_bins = 8;
[t_all_waves,r_all_waves] = rose(result.direction,n_rose_bins);
[t_shuffled_waves,r_shuffled_waves] = rose(result.shuffled_direction,n_rose_bins);
[t_ret_waves,r_ret_waves] = rose(result.direction(result.retinal_events),n_rose_bins);
[t_ctx_waves,r_ctx_waves] = rose(result.direction(result.cortical_events),n_rose_bins);


for i=1:size(data,2)
    % note, preferred direction is compared to real waves
    result.neuron(i).all_events = distil_neuron_results(all_positive_data(:,i), result.direction(~isnan(all_t(:,i))), r_all_waves,n_rose_bins );
    result.neuron(i).retinal_events = distil_neuron_results(all_positive_data(result.retinal_events,i), result.direction(~isnan(all_t(result.retinal_events,i))), r_ret_waves,n_rose_bins);
    result.neuron(i).cortical_events = distil_neuron_results(all_positive_data(result.cortical_events,i), result.direction(~isnan(all_t(result.cortical_events,i))), r_ctx_waves,n_rose_bins);
    result.neuron(i).event_amplitude_ratio = result.neuron(i).retinal_events.amplitude / result.neuron(i).cortical_events.amplitude ;
    result.retinal_participations(i) = result.neuron(i).retinal_events.participation;
    result.retinal_wave_direction_chi2_p(i) = result.neuron(i).retinal_events.wave_direction_chi2_p;
    result.retinal_wave_direction_chi2_p_bonf(i) = min(1,result.retinal_wave_direction_chi2_p(i) * size(data,2)); % bonferroni correction
end
result.event_amplitude_ratios = [result.neuron(:).event_amplitude_ratio];


% rudimentary motion analysis *** deprecated ***
% result = motion_analysis(all_data, all_t,listofcells, listofcellnames, params, process_params, timeint, result);
return
end

function values = distil_neuron_results(data, wave_direction, r_waves,n_rose_bins)
values.amplitude = nanmean( data );
values.participation = sum( ~isnan(data))/ length(data);

% for calculating presence of preferred direction, compared to shuffled
% waves! if preferred direction in network waves, this may or may not be
% reflected in single neurons.
if ~isempty(wave_direction)
    [t,r] = rose( wave_direction,n_rose_bins );
    values.wave_direction_chi2_p = chi2class([r_waves(2:4:end) ;r(2:4:end)]);
    values.wave_direction_mean = phase(mean(exp(sqrt(-1)*wave_direction)));
    values.wave_direction_amplitude = abs(mean(exp(sqrt(-1)*wave_direction)));
else
    values.wave_direction_chi2_p = NaN;
    values.wave_direction_mean = NaN;
    values.wave_direction_amplitude = NaN;
end
return
end


function result = motion_analysis(all_data, all_t,listofcells, listofcellnames, params, process_params, timeint, result)
all_px = repmat([result.cellpositions.x], size(all_data,1),1);
all_py = repmat([result.cellpositions.y], size(all_data,1),1);

non_events = find(isnan(all_t));
all_px(non_events) = NaN;
all_py(non_events) = NaN;

result.xstd = [nanstd(all_px')'];
result.ystd = [nanstd(all_py')'];
result.radius = sqrt(result.xstd.^2+result.ystd.^2);


result.covariance_xt = [ nanmean(all_t.*all_px,2) - nanmean(all_t,2) .* nanmean(all_px,2)];
result.covariance_yt = [ nanmean(all_t.*all_py,2) - nanmean(all_t,2) .* nanmean(all_py,2)];
result.covariance_xyt = sqrt(sum([result.covariance_xt result.covariance_yt].^2,2));
result.crosscor_xyt = result.covariance_xyt ./  ( sqrt( result.xstd.^2 + result.ystd.^2 ) .* result.timestd);

result.velocity_x = result.covariance_xt ./ (result.timestd.^2);
result.velocity_y = -result.covariance_yt ./ (result.timestd.^2); % notice sign change to agree with images
%result.speed = sqrt( result.velocity_x.^2 + result.velocity_y.^2 );
[result.direction, result.speed] = cart2pol(result.velocity_x,result.velocity_y); % direction in radii
result.distance = result.speed .* result.timestd;


figure('name','Motion','numbertitle','off'); % event properties versus participating fraction
figcol = 2;
figrow = 3;
fignum = 1;
subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.participating_fraction,result.crosscor_xyt,'o');
xlabel('Participating fraction');
ylabel('Crosscorrelation x,y and t');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.participating_fraction,result.timestd,'o');
xlabel('Participating fraction');
ylabel('Time std (s)');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.participating_fraction,result.distance,'o');
xlabel('Participating fraction');
ylabel('Traveled distance (pixels)');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.participating_fraction,result.speed,'o');
xlabel('Participating fraction');
ylabel('Speed (pixels/s)');


figure; % speed
figcol = 3;
figrow = 2;
fignum = 1;

subplot(figrow,figcol,fignum); fignum = fignum + 1;
hold on
plot(result.velocity_x,result.velocity_y,'o');
xlabel('Towards medial speed (pix/s) ');
ylabel('Towards rostral speed (pix/s)');
axis equal;
ax = axis;
plot( [ax(1) ax(2)],[0 0],'y-');
plot( [0 0],[ax(3) ax(4)],'y-');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
polar( result.direction,log(result.speed),'o');
title('Log speed');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
rose( result.direction );
title('Direction histogram');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
rose( result.direction(result.cortical_events) );
title('Cortical events');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
rose( result.direction(result.retinal_events) );
title('Retinal events');
return
end

function y = remove_mean( x )
y =x - repmat( nanmean(x,2),1,size(x,2));
end

function plot_event_properties_by_event_number( result)
% event properties ordered by event number
figure;
figcol = 2;
figrow = 2;
fignum = 1;
subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.crosscor_xyt,'o');
xlabel('Event number');
ylabel('Crosscorrelation x,y and t');
subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.timestd,'o');
xlabel('Event number');
ylabel('Time std (s)');
subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.distance,'o');
xlabel('Event number');
ylabel('Traveled distance (pixels)');
subplot(figrow,figcol,fignum); fignum = fignum + 1;
plot(result.speed,'o');
xlabel('Event number');
ylabel('Speed (pixels/s)');
return
end

function fake_wave_analysis( all_data, all_t,listofcells, listofcellnames, params, process_params,timeint, result)
disp('Plotting fake wave for check of wave fitting routines'); %#ok<UNRCH>
% fake waves for calibration of direction and check of wave fitting routines
fake_wave_t = {};
width_x = max([result.cellpositions.x]) - min([result.cellpositions.x]);
width_y = max([result.cellpositions.y]) - min([result.cellpositions.y]);
for c=1:size(all_data,2)
    % in image: > = increase in y; v = increase in x
    fake_dir = 'northeasteast'; %towards, i.e. not like the wind
    %fake_dir = 'west'; %towards, i.e. not like the wind
    switch fake_dir
        case 'north'
            fake_wave_t{1,c} = -result.cellpositions(c).y / width_y * 3  ;
            fake_wave_direction_intended = -pi/2;
            fake_wave_velocity_intended = 1;
        case 'south'
            fake_wave_t{1,c} = result.cellpositions(c).y / width_y * 3;
            fake_wave_direction_intended = pi/2;
            fake_wave_velocity_intended = 1;
        case 'west'
            fake_wave_t{1,c} = -result.cellpositions(c).x / width_x * 3;
            fake_wave_direction_intended = pi;
            fake_wave_velocity_intended = 1;
        case 'east'
            fake_wave_t{1,c} = result.cellpositions(c).x / width_x * 3;
            fake_wave_direction_intended = 0;
            fake_wave_velocity_intended = 1;
        case 'northeast'
            fake_wave_t{1,c} = (result.cellpositions(c).x/width_x -result.cellpositions(c).y/width_y) * 3;
            fake_wave_direction_intended = -pi/4;
            fake_wave_velocity_intended = sqrt(2)/2;
        case 'northeasteast'
            fake_wave_t{1,c} = (result.cellpositions(c).x*2/width_x -result.cellpositions(c).y/width_y)*3  ;
            fake_wave_direction_intended = -0.4636;
            fake_wave_velocity_intended = sqrt(1/5);
        otherwise
            disp('ANALYZE_TPPATTERNS: Unknown fake wave direction');
            return
    end
    fake_wave_data{1,c} = 1;
    %fake_wave_data{1,c} =3*cellpositions(c).x + cellpositions(c).y;
end



% to check direction:
plot_params.what = 'time';
tpshowevents(fake_wave_data,fake_wave_t, listofcells, listofcellnames, params,process_params,[],plot_params)
[result.fake.wave_velocity,result.fake.wave_direction,result.fake.wave_error] = ...
    tp_fit_wave(  [fake_wave_t{:}], result.cellpositions, [fake_wave_data{:}],process_params);
result.fake.timestd = std([fake_wave_t{:}]);
result.fake.participating_fraction = 1;
result.fake.retinal_events = [];
result.fake.cortical_events = 1;

if abs(fake_wave_direction_intended - result.fake.wave_direction)>0.01 || ...
        abs(fake_wave_velocity_intended - result.fake.wave_velocity)>0.01
    disp('Computed fake wave velocity or/and direction are not as intended.');
    keyboard
end

return
end

function result = wave_analysis( all_data, all_t,listofcells, listofcellnames, params, process_params,timeint, result)
% Wave analysis

wave_data = all_data;
wave_t = all_t;
wave_listofcells = listofcells;
wave_listofcellnames = listofcellnames;
wave_cellpositions = result.cellpositions;

% equalize aspect ratio by cropping to a circle
if process_params.wave_aspect_ratio_correction
    disp('ANALYZE_TPPATTERNS: Cropping to circle to get aspect ratio of one. Throwing away data');

    ar_margin = 0.12;
    cc_margin = 0.17;

    x_width = std([wave_cellpositions.x]);
    y_width = std([wave_cellpositions.y]);
   
    aspect_ratio = y_width/x_width;
    cc = corrcoef([wave_cellpositions.x],[wave_cellpositions.y]);
    disp(['ANALYZE_TPPATTERNS: initial aspect_ratio = ' num2str(aspect_ratio)]);
    disp(['ANALYZE_TPPATTERNS: initial cross corr. = ' num2str(cc(1,2))]);
    
    
    while (abs(aspect_ratio-1)>ar_margin || abs(cc(1,2))>cc_margin) && size(wave_data,2)>4 % not square
        centerx = mean([wave_cellpositions.x]);
        centery = mean([wave_cellpositions.y]);
        
        x = [wave_cellpositions.x];
        y = [wave_cellpositions.y];
        x = x - centerx;
        y = y - centery;
        
        if abs(aspect_ratio-1)>ar_margin
            d = x.^2 + y.^2;
        elseif cc(1,2)>cc_margin
            d = x.*y;
        else
            d = -x.*y;
        end
        [md,ind_out] = max( d );  %#ok<ASGLU>
        
        %figure;
      %hold on;
      %plot(centerx,centery,'sr');
      %plot([wave_cellpositions.x],[wave_cellpositions.y],'o');
      %plot([wave_cellpositions.x],[wave_cellpositions.y],'o');
      %plot(wave_cellpositions(ind_out).x,wave_cellpositions(ind_out).y,'*')
      
        ind_inside = setdiff((1:length(wave_cellpositions)),ind_out);
        wave_data = wave_data(:,ind_inside);
        wave_t = wave_t(:,ind_inside);
        wave_listofcells = wave_listofcells(ind_inside);
        if ~isempty(listofcellnames)
            wave_listofcellnames = wave_listofcellnames(ind_inside);
        else
            wave_listofcellnames = wave_listofcellnames;
        end
        wave_cellpositions = wave_cellpositions(ind_inside);

        x_width = std([wave_cellpositions.x]);
        y_width = std([wave_cellpositions.y]);

        aspect_ratio = y_width/x_width;
        cc = corrcoef([wave_cellpositions.x],[wave_cellpositions.y]);
    end
    disp(['ANALYZE_TPPATTERNS: clipped off ' num2str(size(all_data,2)-size(wave_data,2)) ' cells']);
    disp(['ANALYZE_TPPATTERNS: final aspect_ratio = ' num2str(aspect_ratio)]);
    disp(['ANALYZE_TPPATTERNS: final cross corr. = ' num2str(cc(1,2))]);
end

% fake wave analysis for checking analysis
show_fake_wave = false;
if show_fake_wave
    fake_wave_analysis( all_data, all_t,listofcells, listofcellnames, params, process_params,timeint, result); %#ok<UNRCH>
end  

% fit waves
disp('ANALYZE_TPPATTERNS: fitting waves');
[result.velocity,result.direction,result.fiterror] = tp_fit_wave(  wave_t,wave_cellpositions,wave_data,process_params);

% calculate spatial extent (within field of view)
[result.radius] = tp_spatial_extent( wave_t,wave_cellpositions,wave_data,process_params);


% shuffled waves (by randomly taking a set of cells for the given set of times)
disp('ANALYZE_TPPATTERNS: fitting shuffled waves');
result.shuffled_velocity  = NaN*zeros( process_params.wave_zscore_shuffles*size(wave_data,1),1);
result.shuffled_direction = NaN*zeros(size(result.shuffled_velocity));
result.shuffled_fiterror  = NaN*zeros(size(result.shuffled_velocity));
result.shuffled_radius    = NaN*zeros(size(result.shuffled_velocity));
result.shuffled_timestd =                repmat(result.timestd,process_params.wave_zscore_shuffles,1);
result.shuffled_participating_fraction = repmat(result.participating_fraction,process_params.wave_zscore_shuffles,1);
%result.shuffled_all_events =         repmat(result.all_events,process_params.wave_zscore_shuffles,1);
result.shuffled_retinal_events =         repmat(result.retinal_events,process_params.wave_zscore_shuffles,1);
result.shuffled_cortical_events =        repmat(result.cortical_events,process_params.wave_zscore_shuffles,1);


wave_shuffle_method = 'active_cells';
%wave_shuffle_method = 'all_cells';
switch wave_shuffle_method
    case 'all_cells'
        disp('ANALYZE_TPPATTERNS: positions are shuffled. This destroys local clustering of activity without wave shape...');
        disp('I should change that a shuffled the times or positions of the active cells only.');
        
        for i = 1:process_params.wave_zscore_shuffles
            shuffle_cells = randperm( size(wave_data,2) );
            ind = (i-1)*size(wave_data,1)+(1:size(wave_data,1));
            
            [result.shuffled_velocity(ind), result.shuffled_direction(ind), result.shuffled_fiterror(ind), result.shuffled_radius(ind)] = ...
                tp_fit_wave( wave_t, wave_cellpositions(shuffle_cells), wave_data,process_params);
            

        end
        
    case 'active_cells'
        ind = 1;
        for i = 1:process_params.wave_zscore_shuffles
            for j = 1:size(wave_data,1) % waves
                active_cells_ind = find(~isnan(wave_t(j,:)));
                if ~isempty(active_cells_ind)
                    shuffle_cells = randperm( length( active_cells_ind));
                    [result.shuffled_velocity(ind), result.shuffled_direction(ind), result.shuffled_fiterror(ind), result.shuffled_radius(ind)] = ...
                        tp_fit_wave( wave_t(j,active_cells_ind(shuffle_cells)), wave_cellpositions(active_cells_ind), wave_data(j, active_cells_ind),process_params);
                    
                end
                ind = ind + 1;
            end % waves
        end
end

% for spatial extent use all cells in shuffling
        
for i = 1:process_params.wave_zscore_shuffles
    shuffle_cells = randperm( size(wave_data,2) );
    ind = (i-1)*size(wave_data,1)+(1:size(wave_data,1));
    [result.shuffled_radius(ind)] = tp_spatial_extent( wave_t,wave_cellpositions(shuffle_cells),wave_data,process_params);
end

% calculation fraction of shuffle fiterror below error
result.frac_shuffled_below_fiterror = nan * zeros( size(wave_data,1),1);
shuffit = reshape(result.shuffled_fiterror,size(wave_data,1),process_params.wave_zscore_shuffles);
for i=1:size(wave_data,1);
    result.frac_shuffled_below_fiterror(i) = sum(shuffit(i,:)<result.fiterror(i))/process_params.wave_zscore_shuffles;
    result.rand_frac_shuffled_below_fiterror(i) = sum(shuffit(i,:)<shuffit(i,1))/process_params.wave_zscore_shuffles;
end


% calculate zscores
disp('ANALYZE_TPPATTERNS: calculating z-scores');
x = result.shuffled_participating_fraction;
y = result.shuffled_fiterror./result.shuffled_timestd.^2;
x = x(y<1);
y = y(y<1);
% calcute mean and std of shuffled wave error versus participating fraction
[yn,xn,yint] = slidingwindowfunc(x,y,0.1,0.02,1.1,0.2,'mean',0,'std(y)');
% fit mean and std
poly_shufflemean = polyfit(xn,yn,5);
poly_shufflestd = polyfit(xn,yint,5);
% calculate zscores
result.wave_zscore = (result.fiterror./result.timestd.^2 - polyval(poly_shufflemean,result.participating_fraction)) ./ ...
    polyval(poly_shufflestd,result.participating_fraction);

result.shuffled_zscore = (result.shuffled_fiterror./result.shuffled_timestd.^2 - ...
    polyval(poly_shufflemean,repmat(result.participating_fraction,process_params.wave_zscore_shuffles,1))) ./ ...
    polyval(poly_shufflestd,repmat(result.participating_fraction,process_params.wave_zscore_shuffles,1)) ;


% assign wave label to waves according to wave_criterium

%result.waves = (result.wave_zscore < process_params.wave_criterium);
result.waves = (result.frac_shuffled_below_fiterror < 0.1);

result.shuffled_waves = repmat(result.waves,process_params.wave_zscore_shuffles,1);
result.retinal_waves = result.retinal_events & result.waves ;
result.shuffled_retinal_waves = result.shuffled_retinal_events & result.shuffled_waves ;
result.cortical_waves = result.cortical_events & result.waves ;
result.shuffled_cortical_waves = result.shuffled_cortical_events & result.shuffled_waves ;

%result = assign_results( result, 'all' );
%result = assign_results( result, 'retinal' );
%result = assign_results( result, 'cortical' );


wave_ind = find( result.waves );

% show events with z-scores below wave_criterium

plot_params.what = 'time';
if length(wave_ind)>10
    disp('ANALYZE_TPPATTERNS: Too many waves. Only plotting top ten z-scores');
    [temp,ind_sort] = sort(result.wave_zscore(wave_ind)); %#ok<ASGLU>
    wave_ind=wave_ind(ind_sort(1:10));
end



for i=wave_ind(:)'
    comment = ['Wave velocity = ' num2str(result.velocity(i),3) ... 
        ... % ', zscore = ' num2str(result.wave_zscore(i),2) ...
        ', waviness = ' num2str(1-result.frac_shuffled_below_fiterror(i),2) ...
        ',fraction = ' num2str(result.participating_fraction(i),2)];
    if process_params.output_show_waves && process_params.output_show_figures
        tpshowevents(all_data(i,:), all_t(i,:), listofcells, listofcellnames, params,process_params, timeint,plot_params,comment);
    end
end
return
end

% function result = assign_results( result, name )
% % events
% result.([name '_velocity']) = result.velocity(eval(['result.' name '_events']));
% result.([name '_direction']) = result.direction(eval(['result.' name '_events']));
% result.([name '_error']) = result.fiterror(eval(['result.' name '_events']));
% result.(['shuffled_' name '_velocity']) = result.shuffled_velocity(eval(['result.shuffled_' name '_events']));
% result.(['shuffled_' name '_direction']) = result.shuffled_direction(eval(['result.shuffled_' name '_events']));
% result.(['shuffled_' name '_fiterror']) = result.shuffled_fiterror(eval(['result.shuffled_' name '_events']));
% 
% % waves
% result.([name '_wave_velocity']) = result.velocity(eval(['result.waves & result.' name '_events']));
% result.([name '_wave_direction']) = result.direction(eval(['result.waves & result.' name '_events']));
% result.([name '_wave_error']) = result.fiterror(eval(['result.waves & result.' name '_events']));
% result.(['shuffled_' name '_wave_velocity']) = result.shuffled_velocity(eval(['result.shuffled_waves & result.shuffled_' name '_events']));
% result.(['shuffled_' name '_wave_direction']) = result.shuffled_direction(eval(['result.shuffled_waves &result.shuffled_' name '_events']));
% result.(['shuffled_' name '_wave_fiterror']) = result.shuffled_fiterror(eval(['result.shuffled_waves &result.shuffled_' name '_events']));
% 
% 
% end

function [radius] = tp_spatial_extent( wave_t,wave_cellpositions,wave_data,process_params)
radius = nan*zeros(size(wave_t,1),1);
for j=1:size(wave_t,1) % events
    active_cells_ind = find(~isnan(wave_t(j,:)));
    x = [wave_cellpositions(active_cells_ind).x];
    y = [wave_cellpositions(active_cells_ind).y];
    radius(j) = sqrt(std(x)^2+std(y)^2);
end
end



function event_type = characterize_event_type( participating_fraction, timestd, amplitude_participating_cells, process_params)
% characterize events into retinal and cortical
event_type = zeros(size(participating_fraction)); % 0 default
event_type(participating_fraction > process_params.retinal_event_threshold) = 1;  % retinal
event_type(participating_fraction > process_params.cortical_event_threshold) = 2; % cortical
% could also use:
% low_jitter = (result.timestd < 0.5);
% high_amp = (result.amplitude_participating_cells > 0.15);
end

function result = cluster_analysis( data, t, listofcells, listofcellnames, params )
disp('working on cluster analysis in analyze_tppatterns');

imgdata = [];
for cell = 1:size(data,2)
    celldata = [];
    for interval = 1:size(data,1);
        celldata = [celldata data{interval,cell}'];
    end
    imgdata(cell,:) = celldata;
end

% resampling
%disp('resampling....');
%imgdata = resample(imgdata',1,10)';


% to remove zero columns
%m = max( imgdata );
%imgdata = imgdata( :,find(m~=0));



%figure;
%imagesc(imgdata);


%cg = clustergram(imgdata,'cluster',1);
cg = clustergram(imgdata);
colormap jet
result = cg;
end

function result = correlation_analysis( data, t, listofcells, listofcellnames, params )
disp('working on correlation in analyze_tppatterns');

n_cells = length(listofcells);

% calculating maximum imaged time
max_t = 0;
for i=1:n_cells
    if max(t{i}) > max_t
        max_t = max(t{i});
    end
end


imgdata = [];
for cell = 1:size(data,2)
    celldata = [];
    for interval = 1:size(data,1);
        celldata = [celldata data{interval,cell}'];
    end
    imgdata(cell,:) = celldata;
end
imgdata = imgdata(:,any(imgdata>0));

figure;imagesc(imgdata);

% resampling
%disp('resampling....');
%imgdata = resample(imgdata',1,10)';



disp('calculating covariance matrix...');
x=cov(imgdata);
%y=corrcoef(data');


% remove minimum overlap per row
% for i=1:size(x,1);x(i,:)=x(i,:)/max(x(i,:));end;
% for i=1:size(x,1);x(i,:)=x(i,:)/min(x(i,:));end;
for i=1:size(x,1);
    mx(i) = min(x(i,:));
    
end
for i=1:size(x,1);
    x(i,:)=x(i,:)-mx(i);
    x(:,i)=x(:,i)-mx(i);
    %x(i,i)=x(i,i)+mx(i);
end;
% remove minimum overlap per column
%for i=1:size(x,2);x(:,i)=x(:,i)/max(x(:,i));end;
%for i=1:size(x,2);x(:,i)=x(:,i)/min(x(:,i));end;
%for i=1:size(x,2);x(:,i)=x(:,i)-min(x(:,i));end;

figure;
subplot('position',[0.2 0.4 0.8 0.5])
imagesc(x);
title('adjusted covariance');
axis image;
set(gca,'Xaxislocation','top')
%freezeColors
%colormap gray

disp('calculating principal components...');

% principal component analysis
[pc,score,vp]=wpca(x,1); %1
%first principal component pc(:,1)
%explained variance: vp(1)/sum(vp)

disp('calculated principal components...');

% take all pcs with higher than explanation threshold
explanation_threshold = 0.03;
n_pcs = find(vp/sum(vp)> explanation_threshold,'last');


% make pc predominantly positive
for i=1:n_pcs
    pc(:,i) = sign(mean(pc(:,i)))*pc(:,i);
end

subplot('position',[0.1 0.4 0.1 0.5])
imagesc( pc(:,1:n_pcs));
set(gca,'XTick',1:n_pcs);
set(gca,'XTickLabel',fix(100*[vp(1:n_pcs) ]/sum(vp)));
title('PC');
xlabel('explained (%)');

%freezeColors


% calculate for first components the average activity per cell
%mean_activity = mean(imgdata,1);
%figure
%hold on
%plot( mean_activity/max(mean_activity),'k');
%colors = 'brgc';
for i=1:n_pcs
    activity(:,i) = imgdata*pc(:,i);
    %    plot( activity(:,i)/max(activity(:,i)),colors(i));
end

% show pcs as cell activities
%figure;
for i=1:n_pcs
    im{i}=zeros(params.lines_per_frame, params.pixels_per_line);
    for j=1:n_cells
        im{i}(listofcells{j}) = activity(j,i);
    end
    subplot('position',[(i-1)/n_pcs 0 1/n_pcs 0.2]);
    imagesc( im{i});
    
    
    m=max(abs(im{i}(:)));
    set(gca,'clim',[-m m])
    %    cmap=zeros(81,3);
    %    cmap(:,1)=[linspace(1,0,20)';linspace(0,0,20)';linspace(0,1,21)';linspace(1,1,20)'];
    %    cmap(:,2)=[linspace(1,0,20)';linspace(0,0,20)';linspace(0,0,21)';linspace(0,1,20)'];
    %    cmap(:,3)=[linspace(1,1,20)';linspace(1,0,21)';linspace(0,0,20)';linspace(0,0,20)'];
    
    %cmap=zeros(100,3);
    cmap=repmat(linspace(0,1,100)',1,3);
    colormap(cmap);
    colorbar
    axis image
    axis off
    title(['PC ' num2str(i)]);
end
result = [];
return
end
