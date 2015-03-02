function wc_startpi(datapath)
%WC_STARTPI start pi webcam recording
%
%
% 2015, Alexander Heimel
%

pkg load instrument-control
more off

global gNewStim

if nargin<1
    datapath = '';
end

if ~isempty(datapath)
    remotecommglobals
    acqparams_in = fullfile(datapath,'acqParams_in');

    while ~exist(acqparams_in,'file')
        pause(0.01);
    end

acqparams = loadStructArray(acqparams_in);
recording_period = (acqparams.reps + 1) * 10; % s + 10s extra
recording_name = fullfile(datapath,['webcam' num2str(gNewStim.Webcam.WebcamNumber,'%03d.h264')]);
else
    recording_period = 10; % s
    recording_name = 'webcam.h264';
end

s = serial('/dev/ttyUSB0');
fopen(s);

%wc_videorecording(recording_name, [], 0, 1, 1, recording_period)
    prev_cts = get(s,'cleartosend');

tic
system(['raspivid -o ' recording_name ' -w 640 -h 480  -t ' num2str(1000*recording_period)],false,'async' );

stimstart = [];
logmsg(['Started recording to ' recording_name]);
while toc<recording_period && isempty(stimstart)
    cts = get(s,'cleartosend');
    if cts(2)~=prev_cts(2)  % i.e. on and not off
	stimstart =  toc;
        logmsg(['Stimulus started at ' num2str(stimstart) ' s.']);
    end	
    pause(0.05);
end
fclose(s)

fid = fopen([recording_name '_stimstart'],'w');
fprintf(fid,'%f',stimstart);
fclose(fid);


