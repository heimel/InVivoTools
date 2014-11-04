function wc_start(datapath)
%WC_START start webcam recording
%
%
% 2014, Alexander Heimel
%

global WebcamNumber 

if isempty(WebcamNumber)
    WebcamNumber = 1;
end

acqparams = loadStructArray(fullfile(datapath,'acqParams_in'));

recording_period = acqparams.reps * 10; % s
recording_name = fullfile(datapath,['webcam' num2str(WebcamNumber,'%03d')]);


wc_videorecording(recording_name, [], 0, 1, 1, recording_period)
