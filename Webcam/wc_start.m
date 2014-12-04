function wc_start(datapath)
%WC_START start webcam recording
%
%
% 2014, Alexander Heimel
%

global gNewStim

remotecommglobals
%acqparams_in = fullfile(Remote_Comm_dir,'acqParams_in');
acqparams_in = fullfile(datapath,'acqParams_in');


while ~exist(acqparams_in,'file')
    %logmsg(['File ' acqparams_in ' does not exist.']);
    %return
    pause(0.1);
end

acqparams = loadStructArray(acqparams_in);

recording_period = (acqparams.reps + 1) * 10; % s + 10s extra
recording_name = fullfile(datapath,['webcam' num2str(gNewStim.Webcam.WebcamNumber,'%03d')]);



wc_videorecording(recording_name, [], 0, 1, 1, recording_period)
