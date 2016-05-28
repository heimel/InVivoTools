function [radius_smooth,radius,analysed]=analysis_radius(radius,stim_par,timeframe,framerate)
%analysis_radius(radius,stim_par,timeframe,framerate)
%-------------------------------------------------------------------------%
%   Converts radius to radius (were 0 -> NaN).
%   Returns smoothed pupil size signal -> radius_smooth
%   
%   No input needed for timeframe and framerate parameters. Default values
%   are fixed in this scipt.
% 
%   Last edited 27-5-2016. SL
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

% when no input for timeframe is gived, 50 (frames) will be the default value.
if nargin<2
    timeframe = 50;
end

% when no input for timeframe is gived, 50 (frames) will be the default
% value & when no input for framerate is gived, 20 (Hz) will be the default 
% value.
if nargin<3
    timeframe = 50;
    framerate = 20;
end

% find total size of data arrays
[~,number_of_data] = size(radius);

% convert zeros to NaN
for k = 1 : number_of_data
    [a,~]=size(radius(:,k));
    for i = 1:a
        if radius(i,k)==0
            radius(i,k) = NaN;
        end
    end
end
disp(' ');logmsg(' *** Converted zeros to NaN *** ');


% smoothing & averages loop
for k = 1 : number_of_data
    
    % Smoothing
    radius_smooth(:,k) = smooth(radius(:,k),timeframe);

    % Averaging
    % how many seconds: base line
    base_sec = round(framerate * stim_par(k).baseline);

    % how many seconds: stimulus
    meas_start = round((framerate * stim_par(k).baseline) + 1);
    meas_stop  = round((framerate * stim_par(k).baseline) + (framerate * stim_par(k).stim_time) + 1);
    
    % how many seconds: post stimulus
    post_meas_start = round((framerate * stim_par(k).baseline) + (framerate * stim_par(k).stim_time) + 2);
    post_meas_stop  = round((framerate * stim_par(k).baseline) + (framerate * stim_par(k).stim_time) + (framerate * stim_par(k).post_time) + 2);

    % calulate differend averages
    analysed(k).baselinemean  = mean(radius_smooth(1:base_sec));
    analysed(k).mean_tot      = mean(radius_smooth(meas_start:meas_stop));
    if post_meas_stop > numel(radius_smooth)
        post_meas_stop = numel(radius_smooth);
    end
    analysed(k).mean_tot_post = mean(radius_smooth(post_meas_start:post_meas_stop));


end
logmsg(' *** Smoothed pupil radius signal *** ');
logmsg(' *** Calculated averages pupil radius signal *** ');disp(' ');

% calulate differend averages


end