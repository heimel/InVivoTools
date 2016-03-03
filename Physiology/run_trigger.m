function run_trigger(ai,event,settings)
%run_trigger is called when triggered and ensures that session data is
%recorded and saved accordingly
%   
%   The function run_trigger gets the Analog Input Object as an input as
%   well as some event information and parameter settings struct. Each new
%   session is saved to a pre-set data directory (set by the stimulus-PC).
%
%   The data and time variables which are collected by getdata() are stored
%   as one channel each collum. This data is later stored in individual
%   saved varaibles names after the channel names given in the 
%   parameter file.
%   
%
%
%   (c) 15-2-2016, Simon Lansbergen.
% 


% wait to block Matlab during acquisition time, with an additional 0.5
% seconds for safety.
wait(ai,(settings.duration + 0.5));

% get actual data
[data_temp, time] = getdata(ai);


% save file according to channel name
[~,x]=size(settings.hwchannels);
if x == 1
    file_str = cell2mat(settings.hwnames(1));
    save_to = fullfile(settings.data_dir,file_str);
    data = data_temp(:,1);      
    save(save_to,'data','time','settings','-v7');
else 
    for i=1:x
        file_str = cell2mat(settings.hwnames(i));
        save_to = fullfile(settings.data_dir,file_str);
        data = data_temp(:,i);      
        save(save_to,'data','time','settings','-v7');
    end  
    
end

% Done acquiring and saving session data
done_msg = sprintf('\n \n Done acquiring and saving session \n \n');
logmsg(done_msg);

end