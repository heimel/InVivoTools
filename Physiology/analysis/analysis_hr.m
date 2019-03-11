function analysed = analysis_hr(data,settings,stim_par,verbose)
logmsg('DEPRECATED 2019-03-11');

if nargin<4 || isempty(verbose)
    verbose = true;
end

if nargin<3 || isempty(stim_par)
    stim_par.baseline = 10; % ? random
    stim_par.stim_time = 1; % ? random
end

t = data(:,1);





if nargin<2 || isempty(settings)
    settings.max_heart_rate = 30; %Hz, really upper limit
    settings.sample_rate = 1/median(diff(t)); % Hz ?
    
    % for Savitzky-Golayfilter
    settings.poly_order = 0; % guess by Alexander
    settings.window_size = 41; % samples,  random guess by Alexander
    % for smoothening
    settings.sigma = 750; % samples, random guess by Alexander
    % for detrending
    settings.factor = 1; % guess by Alexander
    % for peak detection
    settings.minimal_distance_peaks = ceil(settings.sample_rate / settings.max_heart_rate); % samples
    settings.minimal_height_peaks = 0.5 * pi; %
    
    
    settings.beats = 5; % number of beats to use for moving median
    
    settings.post_time = 1; % ? random
    
    settings
end


data = data(:,2);

if 0
    figure('Name','Raw');
    plotdata(t, data, [0.7 0.7 0.7])
    hold on
end

% Clean data with Savitzky-Golayfilter
analysed.clean = sgolayfilt(data,settings.poly_order,settings.window_size);
logmsg('Savitzky-Golayfilter applied to data');

if verbose
    plotdata(t,analysed.clean,[1 0 0]);
end

%analysed.modulation = smoothen(analysed.clean,settings.sigma);
analysed.modulation = smooth(analysed.clean,settings.sigma);
logmsg('Trend calculated');

analysed.detrend =  analysed.clean - (settings.factor .* analysed.modulation);
logmsg('Trend data used to detrend original data');
%
% if verbose
%     figure('Name','Detrended');
%     plotdata(t, analysed.detrend, [0.7 0.7 0.7])
%     hold on
% end

analysed.hilbert_trans = angle(hilbert(analysed.detrend));
logmsg(' *** Hilbert transform applied to detrended data ***');

%
% if verbose
%     figure('Name','Hilbert transform');
%      plotdata(t, analysed.detrend, [0.7 0.7 0.7])
%      hold on
%      plotdata(t, analysed.hilbert_trans, [1 0 0 ])
%      hold on
% end
%

% find peaks in hilbert transform
[~,analysed.locsThr] = findpeaks(analysed.hilbert_trans,'MinPeakDistance',...
    settings.minimal_distance_peaks,'MINPEAKHEIGHT',settings.minimal_height_peaks);
logmsg(' *** Peak finding algorithm applied to Hilbert transformed data ***');



if verbose
    figure('Name','Hilbert transform');
    n = find(t-t(1) > 1,1);
    

    plot(t(1:n), analysed.detrend(1:n)/max(analysed.detrend(1:n)), 'color',[0.7 0.7 0.7])
    xlim([0 1]);
    xlabel('Time (s)');
    hold on
    plot(t(1:n), analysed.hilbert_trans(1:n)/max(analysed.hilbert_trans(1:n)),'color',[1 0 0 ])
    hold on
    
    ind = find(analysed.locsThr<n);
    
    plot(t(analysed.locsThr(ind)),analysed.hilbert_trans(analysed.locsThr(ind))/max(analysed.hilbert_trans(1:n)),'ok');
end

% calculate interval differences
analysed.peakInterval_1st = diff(analysed.locsThr); % number of samples between beats
analysed.peakInterval_1st = (settings.sample_rate*60)./analysed.peakInterval_1st; % BPM
analysed.peakTime = t(analysed.locsThr(2:end));

logmsg(' *** Instantanous Heart rate calulated ***');

analysed.peakInterval_2nd = diff(analysed.locsThr,2);
logmsg(' *** Differences instantanous HR calulated ***');

% % make correction for faulty peakfinding at first and last data point
% % change the first data point to average of data point 2 to 7.
% analysed(1).peakInterval_1st(1) = mean(analysed(1).peakInterval_1st(2:7));
% % change the last data point to average of data point end-7 to end-1.
% analysed(1).peakInterval_1st(end) = mean(analysed(1).peakInterval_1st(end-7:end-1));


% true difference HR per min, 1st and 2nd der..
% (e.g. normalized per/min)
logmsg(' *** Instantanous HR correction (true value) ***');


% Instantanous HR faulty peaks removed from data
analysed.peakInterval_1st = analysed.peakInterval_1st(2:end-1);
analysed.peakTime = analysed.peakTime(2:end-1);

% save original 2nd der.
analysed.peakInterval_2nd_ori = analysed.peakInterval_2nd;

analysed.peakInterval_2nd = analysed.peakInterval_2nd./max(analysed.peakInterval_2nd);
logmsg(' *** Normalization differences instantanous HR ***');


analysed.avg = movmedian(analysed.peakInterval_1st,settings.beats,'omitnan','Endpoints','shrink');


if verbose
    figure;
    plot(analysed.peakTime,analysed.peakInterval_1st,'k');
    hold
    plot(analysed.peakTime,analysed.avg,'r');
    
    xlabel('Time (s)');
    ylabel('Heart rate (bpm)');
end

logmsg(' *** Heart rate averaged ***');

% heart rate avarages
%seconds = numel(data(1,:));
%step=numel(analysed.avg);
%seconds = seconds / settings.sample_rate;
%[~,index] = size(analysed.peakInterval_1st);

% calculate hr per second
avg_sec = mean(analysed.peakInterval_1st) / 60;

% how many seconds: base line
base_sec = round(avg_sec * stim_par.baseline);
% how many seconds: stimulus
meas_start = round((avg_sec * stim_par.baseline) + 1);
meas_stop  = round((avg_sec * stim_par.baseline) + (avg_sec * stim_par.stim_time) + 1);
% how many seconds: post stimulus
post_meas_start = round((avg_sec * stim_par.baseline) + (avg_sec * stim_par.stim_time) + 2);
post_meas_stop  = round((avg_sec * stim_par.baseline) + (avg_sec * stim_par.stim_time) + (avg_sec * settings.post_time) + 2);

% calulate differend averages
analysed.baselinemean  = mean(analysed.peakInterval_1st(1:base_sec));
analysed.mean_tot      = mean(analysed.peakInterval_1st(meas_start:meas_stop));
if post_meas_stop > numel(analysed.peakInterval_1st)
    post_meas_stop = numel(analysed.peakInterval_1st);
end
analysed.mean_tot_post = mean(analysed.peakInterval_1st(post_meas_start:post_meas_stop));



logmsg('Done with heart rate analysis');

function plotdata( t,data, clr)
subplot(1,2,1);
plot(t,data,'-','Color',clr);
xlim([t(1) t(end)]);
xlabel('Time (s)');
subplot(1,2,2)
n_zoom_samples = find(t-t(1) > 1,1);
i = 1;
plot(t(i:i+n_zoom_samples),data(i:i+n_zoom_samples),'-','Color',clr);
xlim([t(i) t(i+n_zoom_samples)]);
xlabel('Time (s)');
