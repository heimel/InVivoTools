function initwebcampi_async(ready)
%INITWEBCAMPI
% starts recording one long file while checking change in acqReady
%
% 2015, Alexander Heimel
%
more off
pkg load instrument-control
NewStimConfiguration

if nargin<1
    ready=[];
end
if isempty(ready)
    ready=0;
end


%wc_videorecording(recording_name, [], 0, 1, 1, recording_period)
global gNewStim

gNewStim.Webcam.Window = [];
gNewStim.Webcam.WebcamNumber = 1;
gNewStim.Webcam.Camid = [];
gNewStim.Webcam.Rect = [];%[0 0 640 480];
gNewStim.Webcam.Codec = ':CodecType=DEFAULTencoder';
gNewStim.Webcam.WithSound = 0;

remotecommglobals;

acqready = fullfile(Remote_Comm_dir,'acqReady');

theDir = Remote_Comm_dir;
logmsg(['Communicating via ' theDir]);
if ~exist(theDir,'dir')
    msg={['Remote communication folder ' theDir ' does not exist. ']};
    try
        if ~check_network
            msg{end+1} = '';
            msg{end+1} = 'Network connection is unavailable. Check UTP cables, make sure firewall is turned off, or consult with ICT department.';
        else
            msg{end+1} = '';
            msg{end+1} = 'Ethernet connection is working properly. Check NewStimConfiguration or availability of host computer.';
        end
    end
    msg{end+1} = '';
    msg{end+1} = 'Consult NewStim manual troubleshooting section.';
    errormsg(msg);
    return
end
cd(theDir);

if ~Remote_Comm_isremote
    errormsg('Not a remote computer. Change Remote_Comm_isremote in NewStimConfiguration.');
    return
end

acqready_props_prev = dir(acqready);
if isempty(acqready_props_prev)
    acqready_props_prev = [];
    acqready_props_prev.datenum = datenum('2001-01-01');
end

logmsg(['Checking for change in ' acqready]);
while 1 && ~ready
    acqready_props = dir(acqready);
    if ~isempty(acqready_props) && acqready_props.datenum > acqready_props_prev.datenum
        logmsg('acqReady changed');
        acqready_props_prev = acqready_props;
        ready  = 1;
    else
        pause(0.1);
    end
end

fid = fopen(acqready,'r');
fgetl(fid); % pathSpec line
datapath = fgetl(fid);
fclose(fid);

if ~isempty(datapath) && any(datapath==filesep)
    recdatapath = datapath(1:find(datapath==filesep,1,'last'));
end


[recstart,filename] = start_recording(recdatapath);
acqparams_in = fullfile(datapath,'acqParams_in');

pin = 'datasetready';

try
  s = serial('/dev/ttyUSB0');
  fopen(s);
  prev_cts = get(s,pin);
  org_cts = 'on'; %prev_cts; 
  while 1
    cts = get(s,pin);
    if cts(2)~=prev_cts(2) && cts(2)~=org_cts(2)  % i.e. changed and not same as original
	stimstart =  time - recstart;
        logmsg(['Stimulus started at ' num2str(stimstart) ' s.']);

        fid = fopen(acqready,'r');
        fgetl(fid); % pathSpec line
        datapath = fgetl(fid);
        fclose(fid);

	recording_name = fullfile(datapath,['webcam_' host '_info.mat']);
	mkdir(datapath);
	save('-v7',recording_name,'filename','stimstart');
	logmsg(['Saved timing info in ' recording_name]);
    end	
    prev_cts = cts;
    pause(0.05);
  end
catch
    logmsg('HIER');
    stop_recording(filename);
    fclose(s);
   % rethrow(lasterror)
end

logmsg('DAAR');




function [starttime,filename] = start_recording(datapath)

% system('raspivid -t 0 --keypress -o test.h264 -w 640 -h 480 -p 100,100,300,300',false,'async' );
starttime = time;
mkdir(datapath);
filename = fullfile(datapath,['webcam_' host '_' subst_filechars(datestr(now,31)) '.h264'] );
%cmd = ['raspivid -t 0 --keypress -o ' filename ' -w 640 -h 480 -p 100,100,300,300 '];
cmd = ['raspivid -t 0 --keypress -o ' filename ' -w 640 -h 480  '];
system(cmd,false,'async' );
logmsg(['Started recording ' filename ' at ' datestr(now)]);
logmsg('Use Ctrl-C to stop recording');

function stop_recording(filename)
logmsg('Stopping raspivid');
system('pkill raspivid',false,'async');

% possibly need to wrap to mp4
% sudo apt-get install gpac

[stat,output ] = system(['MP4Box -fps 30 -add ' filename ' ' filename '.mp4'],false,'async')
%or
% avconv -i ...h264 -vcodec copy ...mp4
% play video with omxplayer



