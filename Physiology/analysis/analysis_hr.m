function [analysed] = analysis_hr(heart_rate_data,settings,stim_par)


% Clean data with Savitzky-Golayfilter
analysed.clean = sgolayfilt(heart_rate_data,settings.poly_order,settings.window_size);
logmsg(' *** Savitzky-Golayfilter applied to Data ***');

% Get trend/envelope modulation
analysed.modulation = smoothen(analysed.clean,settings.sigma);
logmsg(' *** Trend calculated ***');

% Detrend
analysed.detrend =  analysed.clean - (settings.factor .* analysed.modulation);
logmsg(' *** Trend data used to detrend original data ***');

% perform hilbert transform
analysed.hilbert_trans = angle(hilbert(analysed.detrend));
logmsg(' *** Hilbert transform applied to detrended data ***');

% find peaks in hilbert transform
[~,analysed.locsThr] = findpeaks(analysed.hilbert_trans,'MinPeakDistance',settings.minimal_distance_peaks,'MINPEAKHEIGHT',settings.minimal_height_peaks);
logmsg(' *** Peak finding algorithm applied to Hilbert transformed data ***');

% calculate interval differences
analysed.peakInterval_1st = diff(analysed.locsThr);
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
analysed.peakInterval_1st = (settings.sample_rate*60)./analysed.peakInterval_1st;
logmsg(' *** Instantanous HR correction (true value) ***');

analysed.peakInterval_1st = analysed.peakInterval_1st(2:end-1);
logmsg(' *** Instantanous HR faulty peaks removed from data ***');


% save original 2nd der.
analysed.peakInterval_2nd_ori = analysed.peakInterval_2nd;
logmsg(' *** Intermediate saved variable differences instantanous HR ***');

norm = max(analysed.peakInterval_2nd);
analysed.peakInterval_2nd = analysed.peakInterval_2nd./norm;
logmsg(' *** Normalilzation differences instantanous HR ***');



% calculate average HR, dependend on input beats
total_beats = numel(analysed.peakInterval_1st);
analysed.avg      = [];
temp     = [];
counter  = 1;

for i = 1:settings.beats:total_beats     % step 1 : Main Loop. beats = max 10

    if (i+1) <= total_beats && settings.beats >= 1
    temp(1) = analysed.peakInterval_1st(i);
    end
    
    if (i+2) <= total_beats && settings.beats >= 2
    temp(2) = analysed.peakInterval_1st(i + 1);
    end
    
    if (i+3) <= total_beats && settings.beats >= 3
    temp(3) = analysed.peakInterval_1st(i + 2);
    end
    
    if (i+4) <= total_beats && settings.beats >= 4
    temp(4) = analysed.peakInterval_1st(i + 3);
    end
    
    if (i+5) <= total_beats && settings.beats >= 5
    temp(5) = analysed.peakInterval_1st(i + 5);
    end
    
    if (i+6) <= total_beats && settings.beats >= 6
    temp(6) = analysed.peakInterval_1st(i + 6);
    end
    
    if (i+7) <= total_beats && settings.beats >= 7
    temp(7) = analysed.peakInterval_1st(i + 7);
    end
    
    if (i+8) <= total_beats && settings.beats >= 8
    temp(8) = analysed.peakInterval_1st(i + 8);
    end
    
    if (i+9) <= total_beats && settings.beats >= 9
    temp(9) = analysed.peakInterval_1st(i + 9);
    end
    
    if (i+10) <= total_beats && settings.beats >= 10
    temp(10) = analysed.peakInterval_1st(i + 10);
    end

% step 2 
analysed.avg(counter) = mean(temp);

% step 3 : add step to counters
counter = counter + 1;
temp=[];
end
logmsg(' *** Heart rate averaged ***');

%
%
%
% heart rate avarages
seconds = numel(heart_rate_data(1,:));
step=numel(analysed.avg);
seconds = seconds / settings.sample_rate;
[~,index] = size(analysed.peakInterval_1st);

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
logmsg(' *** Calculated Averages ***');


disp(' ');logmsg(' *** Done Analyzing ***');disp(' ');
end