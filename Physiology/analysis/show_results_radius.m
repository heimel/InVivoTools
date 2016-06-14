function show_results_radius(radius_woz,radius_smooth,framerate,stim_par)
%show_results_radius(radius_woz,radius_smooth,framerate,stim_par)
%-------------------------------------------------------------------------%
% 
%   Last edited 28-5-2016. SL
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

% when no value for framerate is given, the default is 20 Hz.
if nargin<3
    framerate = 20;
end

close all

[a,~]=size(radius_woz);

% show radius results
figure
subplot(3,1,1)
plot(linspace(0,a/framerate,a),radius_woz,'r','LineWidth',3)
grid on
title('Original pupil size signal')
xlabel('Seconds (s)')
ylabel('Pixels (Pix)')

subplot(3,1,2)
plot(linspace(0,a/framerate,a),radius_woz,'k',linspace(0,a/framerate,a),radius_smooth,'r','LineWidth',2)
grid on
title('Smoothed and original pupil size signal')
xlabel('Seconds (s)')
ylabel('Pixels (Pix)')
legend('Original','Smoothed')

subplot(3,1,3)
plot(linspace(0,a/framerate,a),radius_smooth,'r','LineWidth',3)
grid on
title('Smoothed pupil size signal')
xlabel('Seconds (s)')
ylabel('Pixels (Pix)')



%%%
%%%
% Plot averages and smoothed radius signal
%%%

% time variables to set x-axis and round up to integers
b     = round(stim_par.baseline);
b_s   = round(stim_par.baseline + stim_par.stim_time);
b_s_p = round(stim_par.baseline + stim_par.stim_time + stim_par.post_time);

x          = 0:b;
x_tot      = 0:b_s;
x_tot_post = 0:b_s_p;

mean_tot      = NaN(1,(b_s   + 1));
mean_tot_post = NaN(1,(b_s_p + 1));

% Averaging
% how many seconds: base line
base_sec = round(framerate * stim_par.baseline);
% how many seconds: stimulus
meas_start = round((framerate * stim_par.baseline) + 1);
meas_stop  = round((framerate * stim_par.baseline) + (framerate * stim_par.stim_time) + 1);  
% how many seconds: post stimulus
post_meas_start = round((framerate * stim_par.baseline) + (framerate * stim_par.stim_time) + 2);
post_meas_stop  = round((framerate * stim_par.baseline) + (framerate * stim_par.stim_time) + (framerate * stim_par.post_time) + 2);

% calulate differend averages
baslinemean(1:(b + 1))       = mean(radius_smooth(1:base_sec));
mean_tot((b + 1):(b_s + 1))  = mean(radius_smooth(meas_start:meas_stop));
if post_meas_stop > numel(radius_smooth)
    post_meas_stop = numel(radius_smooth);
end
mean_tot_post((b_s + 1):(b_s_p + 1)) = mean(radius_smooth(post_meas_start:post_meas_stop));

% Plot graph
figure
hold on
plot(x,baslinemean,'k','LineWidth',3)
plot(x_tot,mean_tot,'g','LineWidth',3)
plot(x_tot_post,mean_tot_post,'m','LineWidth',3)
plot(linspace(0,a/framerate,a),radius_smooth,'r','LineWidth',2)
hold off
% xlim([settings.rangex_min, settings.rangex_max])
% ylim([settings.rangey_min, settings.rangey_max])
grid on
xlabel('Seconds (sec)')
ylabel('Pixels (pix)')
% title(data_name)
legend('baseline','average measurement','post measurement','Pupil radius size')


end