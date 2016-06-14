%RUN_ANALYSIS_RADIUS.m
%-------------------------------------------------------------------------%
%   
%   
%   
%   Last edited 27-5-2016. SL
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%
% Initialisation
clear all       % Clear all variables in workspace
close all       % Close all current windows with figures (plots)
clc             % Clear Command window
%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                  Settings                %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run = true;     % Load and analyse data
% run = false;

show_graph = true;  % show data
% show_graph = false;

% time frame for averaging filter -> amount of frames which is used in
% averaging. When not set, default is 50.
timeframe = 50;

framerate = 20;

% post time after stimulus (seconds) has to be given manually
% when no value for post_time is given, the default is 10.
post_time = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                  Load Data               %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if run
date = '2016-5-23';
variable_name = 'pupil_mouse.txt'
[radius, stim_par] = load_radius_data(date,variable_name,post_time);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                  Analyze                 %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[radius_smooth,radius,analysed] = analysis_radius(radius,stim_par,timeframe,framerate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%              Graphs Data                 %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stim_par(1).baseline = 15;
stim_par(1).stim_time = 15;
stim_par(1).post_time = 20;

if show_graph == true
    for i = 1:numel(stim_par)
        show_results_radius(radius(:,i),radius_smooth(:,i),framerate,stim_par(i))
        input(' *** Hit Enter to continue ***')
    end
end



