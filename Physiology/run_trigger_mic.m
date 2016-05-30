function run_trigger_mic(ai_mic,event_mic,settings)
%run_trigger_mic is called when triggered and ensures that session data is
%recorded and saved accordingly for the dedicated microphone config
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
%   (c) 2016, Simon Lansbergen.
% 

% wait to block Matlab during acquisition time, with an additional 0.5
% seconds for safety.
wait(ai_mic,(settings.duration + 0.5));

% get actual data
[data, time] = getdata(ai_mic);

% save both time and data, as well as hardware and c
% file_str = 'ultra_sound_data';
file_str_wav = 'ultra_sound_data.wav';
% save_to = fullfile(settings.data_dir,file_str);
save_to_wav = fullfile(settings.data_dir,file_str_wav);

channel_settings = ai_mic.Channel;
% save(save_to,'data','time','settings','-v7');

% beta: write directly as wav to save space
Fs = 250000; % sample rate mic -> get automatically!
audiowrite(save_to_wav,data,Fs);

% Done acquiring and saving session data
done_msg = sprintf('\n \n Done acquiring and saving microphone recordings \n \n');
logmsg(done_msg);

end