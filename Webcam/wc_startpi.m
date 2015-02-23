function wc_startpi(datapath)
%WC_STARTPI start pi webcam recording
%
%
% 2015, Alexander Heimel
%

global gNewStim

remotecommglobals
acqparams_in = fullfile(datapath,'acqParams_in');

while ~exist(acqparams_in,'file')
    pause(0.01);
end

acqparams = loadStructArray(acqparams_in);
recording_period = (acqparams.reps + 1) * 10; % s + 10s extra
recording_name = fullfile(datapath,['webcam' num2str(gNewStim.Webcam.WebcamNumber,'%03d.h264')]);

%wc_videorecording(recording_name, [], 0, 1, 1, recording_period)

system(['raspivid -o ' recording_name '  -t ' num2str(1000*recording_period)],false,'async' );

logmsg(['Started recording to ' recording_name]);

