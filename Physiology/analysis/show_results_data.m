function [avg,avg_br]=show_results_data(analysed,analysed_br,time,settings,baseline,stim_time,data_name,show_all)

settings.pre_time  = baseline;
settings.stim_time = stim_time;

close all;
logmsg(' *** showing graphs ***');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%      Graphs     DATA    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% heart rate + avarage
[~,seconds] = size(time);
seconds = seconds / settings.sample_rate;
[~,index] = size(analysed.peakInterval_1st);
timed_hr = linspace(0,seconds,index);        

% calculate hr per second
avg_hr_sec = mean(analysed.peakInterval_1st) / 60;

% how many seconds: base line
base_sec = round(avg_hr_sec * settings.pre_time);
% how many seconds: stimulus
meas_start = round((avg_hr_sec * settings.pre_time) + 1);
meas_stop  = round((avg_hr_sec * settings.pre_time) + (avg_hr_sec * settings.stim_time) + 1);
% how many seconds: post stimulus
post_meas_start = round((avg_hr_sec * settings.pre_time) + (avg_hr_sec * settings.stim_time) + 2);
post_meas_stop  = round((avg_hr_sec * settings.pre_time) + (avg_hr_sec * settings.stim_time) + (avg_hr_sec * settings.post_time) + 2);

% time variables to set x-axis and round up to integers
b     = round(settings.pre_time);
b_s   = round(settings.pre_time + settings.stim_time);
b_s_p = round(settings.pre_time + settings.stim_time + settings.post_time);

x          = 0:b;
x_tot      = 0:b_s;
x_tot_post = 0:b_s_p;

mean_tot      = NaN(1,(b_s   + 1));
mean_tot_post = NaN(1,(b_s_p + 1));

% calulate differend averages
baslinemean(1:(b + 1))       = mean(analysed.peakInterval_1st(1:base_sec));
mean_tot((b + 1):(b_s + 1))  = mean(analysed.peakInterval_1st(meas_start:meas_stop));
if post_meas_stop > numel(analysed.peakInterval_1st)
    post_meas_stop = numel(analysed.peakInterval_1st);
end
mean_tot_post((b_s + 1):(b_s_p + 1)) = mean(analysed.peakInterval_1st(post_meas_start:post_meas_stop));

if show_all == 1
    
% plot figure
figure
hold on
plot(timed_hr,analysed.peakInterval_1st,'r','LineWidth',2);
plot(x,baslinemean,'b','LineWidth',2)
plot(x_tot,mean_tot,'g','LineWidth',2)
plot(x_tot_post,mean_tot_post,'m','LineWidth',2)
hold off
xlim([settings.rangex_min, settings.rangex_max])
ylim([settings.rangey_min, settings.rangey_max])
xlim([0 seconds])
legend('Heart Rate')
title(data_name)
grid on


% cleaned data + normalized relative heart rate change     
[~,index2] = size(analysed.peakInterval_2nd);
timed_hr2 = linspace(0,seconds,index2);

figure
hold on
plot(time,analysed.clean);
plot(timed_hr2,analysed.peakInterval_2nd,'r','LineWidth',2);
hold off
xlim([settings.rangex_min, settings.rangex_max])
xlabel('Seconds')
title(data_name)
grid on


% examples removing trend
figure
subplot(1,2,1)
plot(time,analysed.clean,time,analysed.modulation,'r','LineWidth',2)
xlim([settings.rangex_min, settings.rangex_max])
legend('cleaned data','trend')
xlabel('Seconds')
title(data_name)
grid on
subplot(1,2,2)
plot(time,analysed.clean,'g-.',time,analysed.detrend,'r','LineWidth',2)
xlim([settings.rangex_min, settings.rangex_max])
legend('original cleaned data','cleaned and de-trended')
xlabel('Seconds')
title(data_name)
grid on


% detrended data + relative heart rate differences
figure
grid on
hold on
plot(time,analysed.detrend);
plot(timed_hr2,analysed.peakInterval_2nd,'r','LineWidth',2);
hold off
xlim([settings.rangex_min, settings.rangex_max])
xlabel('Seconds')
legend('de-trended data','relative change HR')
title(data_name)

% show found peaks      
figure
hold on
% plot(1:numel(time),analysed.clean);
% plot(analysed.locsThr,analysed.clean(analysed.locsThr),'rv','MarkerFaceColor','r');
plot(1:numel(time),analysed.detrend);
plot(analysed.locsThr,analysed.detrend(analysed.locsThr),'rv','MarkerFaceColor','r');
hold off
xlabel('Seconds')
title(data_name)


end

% show instant heart rate + average hr + baseline etc.
step=numel(analysed.avg);
[~,total_beats] = size(analysed.peakInterval_1st);
x1=linspace(0,seconds,total_beats);
x2=linspace(0,seconds,step);

figure
hold on
plot(x,baslinemean,'k','LineWidth',3)
plot(x_tot,mean_tot,'g','LineWidth',3)
plot(x_tot_post,mean_tot_post,'m','LineWidth',3)
plot(x1,analysed.peakInterval_1st,'--')
plot(x2,analysed.avg,'r','LineWidth',2)
hold off
xlim([settings.rangex_min, settings.rangex_max])
ylim([settings.rangey_min, settings.rangey_max])
grid on
xlabel('Seconds (sec)')
ylabel('Heart Rate (p/m)')
title(data_name)
legend('baseline','average measurement','post measurement','instantanous HR','average HR')



%
%
%
% breath rate + avarage
seconds = numel(time);
step=numel(analysed_br.avg);
seconds = seconds / settings.sample_rate;
[~,index] = size(analysed_br.peakInterval_1st);


% calculate hr per second
avg_br_sec = mean(analysed_br.peakInterval_1st) / 60;

% how many seconds: base line
base_sec = round(avg_br_sec * settings.pre_time);
% how many seconds: stimulus
meas_start = round((avg_br_sec * settings.pre_time) + 1);
meas_stop  = round((avg_br_sec * settings.pre_time) + (avg_br_sec * settings.stim_time) + 1);
% how many seconds: post stimulus
post_meas_start = round((avg_br_sec * settings.pre_time) + (avg_br_sec * settings.stim_time) + 2);
post_meas_stop  = round((avg_br_sec * settings.pre_time) + (avg_br_sec * settings.stim_time) + (avg_br_sec * settings.post_time) + 2);

% time variables to set x-axis and round up to integers
b     = round(settings.pre_time);
b_s   = round(settings.pre_time + settings.stim_time);
b_s_p = round(settings.pre_time + settings.stim_time + settings.post_time);

x          = 0:b;
x_tot      = 0:b_s;
x_tot_post = 0:b_s_p;
x1=linspace(0,seconds,index);
x2=linspace(0,seconds,step);

mean_tot_br      = NaN(1,(b_s   + 1));
mean_tot_post_br = NaN(1,(b_s_p + 1));

% calulate differend averages
baselinemean_br(1:(b + 1))       = mean(analysed_br.peakInterval_1st(1:base_sec));
mean_tot_br((b + 1):(b_s + 1))  = mean(analysed_br.peakInterval_1st(meas_start:meas_stop));
if post_meas_stop > numel(analysed_br.peakInterval_1st)
    post_meas_stop = numel(analysed_br.peakInterval_1st);
end
mean_tot_post_br((b_s + 1):(b_s_p + 1)) = mean(analysed_br.peakInterval_1st(post_meas_start:post_meas_stop));

figure
hold on
plot(x,baselinemean_br,'k','LineWidth',3)
plot(x_tot,mean_tot_br,'g','LineWidth',3)
plot(x_tot_post,mean_tot_post_br,'m','LineWidth',3)
plot(x1,analysed_br.peakInterval_1st,'--')
plot(x2,analysed_br.avg,'r','LineWidth',2)
hold off
xlim([settings.rangex_min, settings.rangex_max])
grid on
xlabel('Seconds (sec)')
ylabel('Breath Rate (p/m)')
title(data_name)
legend('baseline','average measurement','post measurement','instantanous BR','average BR')


end