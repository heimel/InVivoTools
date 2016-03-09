%RUN_ANALYSIS.m
%-------------------------------------------------------------------------%
%
%   Main script for analyzing recording data InVivoTools - Physiology
%   toolbox.
%
%   Script needs to be runned while activly in dropbox\nin\data\
%   
%   Used scripts:
%       analysis.m
%       analysis_br.m
%       load_data.m
%       show_results_data.m
%       
%
%
%   Last edited 6-3-2016. SL
%
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% Initialisation
% clear all       % Clear all variables in workspace
close all       % Close all current windows with figures (plots)
clc             % Clear Command window
% run = true;     % Load and analyse data
run = false;
%-------------------------------------------------------------------------%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                  Load Data               %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if run
% date = '22-2-2016';
date = '29-2-2016';
[data, stim_par] = load_data(date);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                  Settings                %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Savitzky-Golayfilter settings
settings.window_size = 501;             % needs to be odd
settings.poly_order = 1;                % polynomal order for fitting function

% Sigma setting for Gaussian smoothing
settings.sigma = 750;

% Amplification factor trend
settings.factor = 1.5;

% Settings peakfinder() algorithm
settings.minimal_distance_peaks = 850;  % which means at least 85 msec between peaks in HR (85 msec peak to peak equals a HR of +700 per min)
settings.minimal_height_peaks = 0.1; % set the minimum height to be slightly over 0 to ensure that no negative peaks are collected

% Sample rate
settings.sample_rate = 10000;

% Number of beats for averaging
settings.beats = 8;

% Has to be set manually
settings.post_time = 7.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                  Analyze                 %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if run


for i = 2:numel(data(:,1))
[analysed(i-1,:)] = analysis(data(i,:),settings,stim_par(i));    
[analysed_br(i-1,:)] = analysis_br(analysed(i-1).modulation,settings,stim_par(i));
end

% calculate mean of different periods
[base,stim,post]=mean_period(analysed,analysed_br);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%              Graphs Data                 %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


data_set_num  = 22;
name_data_set = 'data 22';
show_all      = false;

% Set range in seconds (0 to 21), default 0 to 20
settings.rangex_min = 0;
settings.rangex_max = 35;
% set range y-axis in heart rate graphs
settings.rangey_min = 320;
settings.rangey_max = 480;

show_results_data(analysed(data_set_num,:),analysed_br(data_set_num,:),data(1,:),settings,name_data_set,show_all);


% plot baseline, stimulus and post-time averages.
figure 
x=1:(numel(base.avg));
subplot(1,2,1)
hold on
plot(x,base.avg,'k',x,post.avg,'m','LineWidth',2)
plot(x,stim.avg,'g','LineWidth',2.5)
hold off 
grid on
legend('pre','post','stim')
title(date)
subplot(1,2,2)
hold on
plot(x,base.avg_br,'k',x,post.avg_br,'m','LineWidth',2)
plot(x,stim.avg_br,'g','LineWidth',2.5)
legend('pre','post','stim')
hold off
grid on
title(date)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%              Statistics                  %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp(' Mean baseline all data (HR) :');disp(mean(base.avg));
disp(' Mean stimulus all data (HR) :');disp(mean(base.avg));
disp(' Mean post time all data (HR) :');disp(mean(post.avg));

disp(' Mean baseline all data (BR) :');disp(mean(base.avg_br));
disp(' Mean stimulus all data (BR) :');disp(mean(stim.avg_br));
disp(' Mean post time all data (BR) :');disp(mean(post.avg_br));

% Statistics
figure
subplot(1,3,1)
qqplot(stim.avg,post.avg);
title('QQ-plot Average stimulus against post-time');
grid on
subplot(1,3,2)
qqplot(stim.avg,base.avg);
title('QQ-plot Average stimulus against baseline');
grid on
subplot(1,3,3)
qqplot(base.avg,post.avg);
title('QQ-plot Average baseline against post-time');
grid on

[h_stim_vs_post, p_stim_vs_post] = ttest(stim.avg,post.avg,'Alpha',0.05)
[h_stim_vs_base, p_stim_vs_base] = ttest(stim.avg,base.avg,'Alpha',0.05)
[h_base_vs_post, p_base_vs_post] = ttest(base.avg,post.avg,'Alpha',0.05)

