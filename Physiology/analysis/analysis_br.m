function [analysed_br] = analysis_br(breath_rate_data,settings,stim_par)

% perform hilbert transform
analysed_br.hilbert_trans = angle(hilbert(breath_rate_data));
logmsg(' *** Hilbert transform applied to breath rate ***');

% find peaks in hilbert transform
[~,analysed_br.locsThr] = findpeaks(analysed_br.hilbert_trans,'MinPeakDistance',settings.minimal_distance_peaks,'MINPEAKHEIGHT',settings.minimal_height_peaks);
logmsg(' *** Peak finding algorithm applied to Hilbert transformed data ***');

% calculate interval differences
analysed_br.peakInterval_1st = diff(analysed_br.locsThr);
logmsg(' *** Instantanous Breath rate calulated ***');

analysed_br.peakInterval_2nd = diff(analysed_br.locsThr,2);
logmsg(' *** Differences instantanous BR calulated ***');

% true difference BR per min, 1st der..
% (e.g. normalized per/min)
analysed_br.peakInterval_1st = (settings.sample_rate*60)./analysed_br.peakInterval_1st;
logmsg(' *** Instantanous BR correction (true value) ***');

analysed_br.peakInterval_1st = analysed_br.peakInterval_1st(2:end-1);
logmsg(' *** Instantanous BR faulty peaks removed from data ***');

% calculate average breath rate, dependend on input beats
total_beats     = numel(analysed_br.peakInterval_1st);
analysed_br.avg = [];
temp            = [];
counter         = 1;

for i = 1:settings.beats:total_beats     % step 1 : Main Loop. beats = max 10

    if (i+1) <= total_beats && settings.beats >= 1
    temp(1) = analysed_br.peakInterval_1st(i);
    end
    
    if (i+2) <= total_beats && settings.beats >= 2
    temp(2) = analysed_br.peakInterval_1st(i + 1);
    end
    
    if (i+3) <= total_beats && settings.beats >= 3
    temp(3) = analysed_br.peakInterval_1st(i + 2);
    end
    
    if (i+4) <= total_beats && settings.beats >= 4
    temp(4) = analysed_br.peakInterval_1st(i + 3);
    end
    
    if (i+5) <= total_beats && settings.beats >= 5
    temp(5) = analysed_br.peakInterval_1st(i + 5);
    end
    
    if (i+6) <= total_beats && settings.beats >= 6
    temp(6) = analysed_br.peakInterval_1st(i + 6);
    end
    
    if (i+7) <= total_beats && settings.beats >= 7
    temp(7) = analysed_br.peakInterval_1st(i + 7);
    end
    
    if (i+8) <= total_beats && settings.beats >= 8
    temp(8) = analysed_br.peakInterval_1st(i + 8);
    end
    
    if (i+9) <= total_beats && settings.beats >= 9
    temp(9) = analysed_br.peakInterval_1st(i + 9);
    end
    
    if (i+10) <= total_beats && settings.beats >= 10
    temp(10) = analysed_br.peakInterval_1st(i + 10);
    end

% step 2 
analysed_br.avg(counter) = mean(temp);

% step 3 : add step to counters
counter = counter + 1;
temp=[];
end
logmsg(' *** Breath rate averaged ***');


%
%
%
% breath rate avarages
seconds = numel(breath_rate_data(1,:));
step=numel(analysed_br.avg);
seconds = seconds / settings.sample_rate;
[~,index] = size(analysed_br.peakInterval_1st);

% calculate hr per second
avg_sec = mean(analysed_br.peakInterval_1st) / 60;

% how many seconds: base line
base_sec = round(avg_sec * stim_par.baseline);
% how many seconds: stimulus
meas_start = round((avg_sec * stim_par.baseline) + 1);
meas_stop  = round((avg_sec * stim_par.baseline) + (avg_sec * stim_par.stim_time) + 1);
% how many seconds: post stimulus
post_meas_start = round((avg_sec * stim_par.baseline) + (avg_sec * stim_par.stim_time) + 2);
post_meas_stop  = round((avg_sec * stim_par.baseline) + (avg_sec * stim_par.stim_time) + (avg_sec * settings.post_time) + 2);

% calulate differend averages
analysed_br.baselinemean_br  = mean(analysed_br.peakInterval_1st(1:base_sec));
analysed_br.mean_tot_br      = mean(analysed_br.peakInterval_1st(meas_start:meas_stop));
if post_meas_stop > numel(analysed_br.peakInterval_1st)
    post_meas_stop = numel(analysed_br.peakInterval_1st);
end
analysed_br.mean_tot_post_br = mean(analysed_br.peakInterval_1st(post_meas_start:post_meas_stop));
logmsg(' *** Calculated Averages ***');





disp(' ');logmsg(' *** Done Analyzing breath rate ***');disp(' ');

end