function run_trigger(ai,event,settings)
%run_trigger is called when triggered and ensures that session data is
%recorded and saved accordingly
%   
%   The function run_trigger gets the Analog Input Object as an input as
%   well as some event information and parameter settings struct. Each new
%   session is saved to a pre-set data directory (set by the stimulus-PC).
%
%   The data and time variables which are collected by getdata() are stored
%   as one channel each collum. So when multiple channels are simultaneously
%   saved, all data is stored in one variable with number of collums
%   related to the configured channels.
%   
%   Calculates the heart and breath rate by Gaussian smoothing at a pre set
%   value, which can be changed in daq_parameters settings script.
%
%       -> TO DO: make Gaussian blur variable availible in script!
%
%   (c) 2016, Simon Lansbergen.
% 


% wait to block Matlab during acquisition time, with an additional 0.5
% seconds for safety.
wait(ai,(settings.duration + 0.5));

% get actual data
[data, time] = getdata(ai);

smooth_hr = smoothen(data,150);        % Smoothen heart rate
smooth_br = smoothen(data,1000);       % Smoothen breath rate

% save both time and data, as well as hardware and configution
file_str = 'physiological_data';
save_to = fullfile(settings.data_dir,file_str);
channel_settings = ai.Channel;
save(save_to,'data','smooth_br','smooth_hr','time','settings','-v7');

% Done acquiring and saving session data
done_msg = sprintf('\n \n Done acquiring and saving session \n \n');
logmsg(done_msg);

end