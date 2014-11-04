function wc_start(datapath)
%WC_START start webcam recording
%
%
% 2014, Alexander Heimel
%

global WebcamNumber 
remotecommglobals

if isempty(WebcamNumber)
    WebcamNumber = 1;
end

acqparams_in = fullfile(Remote_Comm_dir,'acqParams_in');
if ~exist(acqparams_in,'file')
    logmsg(['File ' acqparams_in ' does not exist.']);
    return
end

acqparams = loadStructArray(acqparams_in);

recording_period = (acqparams.reps + 3) * 10; % s + 30s extra
recording_name = fullfile(datapath,['webcam' num2str(WebcamNumber,'%03d')]);

wc_videorecording(recording_name, [], 0, 1, 1, recording_period)
