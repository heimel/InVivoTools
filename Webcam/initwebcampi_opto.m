function initwebcampi_opto(ready)
%INITWEBCAMPI
% starts recording one long file while checking change in acqReady
%
% 2015-2018, Alexander Heimel
%
more off
pkg load instrument-control
NewStimConfiguration
StimSerialGlobals

params = wcprocessparams;

if nargin<1 || isempty(ready)
    ready = 0;
end


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
    acqready_props_prev.datenum = datenum('01/01/2001');
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

if isunix
  datapath(datapath=='\') = '/';
end 

if ~isempty(datapath) && any(datapath==filesep)
    recdatapath = datapath(1:find(datapath==filesep,1,'last'));
end

logmsg('Finding serial port')
s1 = [];
for i = 1:10
    devfolder = strcat('/dev/ttyUSB',num2str(i-1));
    if ~isempty(dir(devfolder))
        s1 = serial(devfolder);
        logmsg(['Found one at '  devfolder]);
        break
    end
end

[recstart,filename] = start_recording(recdatapath,params);


if ~isa(s1,'octave_serial') && ~isa(s1,'serial')
    logmsg('Could not find serial port of form /dev/ttyUSB*');
    try
        while 1
            pause(0.01);
        end
    catch me
        logmsg(me.message);
        stop_recording(filename);
    end
else
    
    acqparams_in = fullfile(datapath,'acqParams_in');
    try
        if strcmp(devfolder,StimSerialScriptIn)
            switch StimSerialScriptInPin
                case 'dsr'
                    pin = 'DataSetReady';
                case 'cts'
                    pin = 'ClearToSend';
            end
        else
            pin = 'DataSetReady';
        end
        
        logmsg(['Serial pin for script start: ' pin]);
        
        optopin = 'ClearToSend';
        logmsg(['Serial pin for optogenetics: ' optopin]);
        
        
        
        fopen(s1);
        
        get(s1)
        
        %edit Sven april 2015: Made compatible with two versions of instrument-control
        if isfield(get(s1),'pinstatus')
            new_instr_contr = 1;
        else
            new_instr_contr = 0;
            pin = lower(pin);
        end
        
        if new_instr_contr
            s2 = get(s1,'pinstatus');
            prev_cts = s2.(pin);
        else
            prev_cts = get(s1,pin);
        end
        
        org_cts = prev_cts;
        optogenetic_stimulation = false;
        
        logmsg('Press q to quit');
        while 1 % loop to find trigger
            
            if new_instr_contr
                s2 = get(s1,'pinstatus');
                cts = s2.(pin);
                opto = s2.(optopin);
            else
                cts = get(s1,pin);
                opto = get(s1,optopin);
            end
            
            if ~optogenetic_stimulation
                if strcmp(opto,'on')
                    logmsg('Starting optogenetic stimulation');
                    optopulse; 
                    optogenetic_stimulation = true;
                end
            else 
                if strcmp(opto,'off')
                    logmsg('Stopping optogenetic stimulation');
                    system('pkill optopulse');
                    optopulse(0);
                    optogenetic_stimulation = false;
                end
            end
            
            if cts(2)~=prev_cts(2) && cts(2)~=org_cts(2)  % i.e. changed and not same as original
                stimstart =  time - recstart;
                logmsg(['Stimulus started at ' num2str(stimstart) ' s.']);
                
                fid = fopen(acqready,'r');
                fgetl(fid); % pathSpec line
                datapath = fgetl(fid);
                fclose(fid);
                if isunix
                    datapath(datapath=='\') = '/';
                end 
                recording_name = fullfile(datapath,['webcam_' host '_info.mat']);
                mkdir(datapath);
                save('-v7',recording_name,'filename','stimstart');
                logmsg(['Saved timing info in ' recording_name]);
                logmsg('Press q to quit');
            end
            prev_cts = cts;
            pause(0.01);
            if exist('KbCheck','file')
              [keydown,~,keycode] = KbCheck;
              if keydown && keycode(25) % 'q
                  logmsg('Pressed q');
                  stop_recording(filename);
                  fclose(s1);
              end
            end
        end
    catch me
        logmsg(me.message);
        stop_recording(filename);
        fclose(s1);
    end
end



function [starttime,filename] = start_recording(datapath,params)

% system('raspivid -t 0 --keypress -o test.h264 -w 640 -h 480 -p 100,100,300,300',false,'async' );
mkdir(datapath);
filename = fullfile(datapath,['webcam_' host '_' subst_filechars(datestr(now,31)) '.h264'] );
%cmd = ['raspivid -t 0 --keypress -o ' filename ' -w 640 -h 480 -p 100,100,300,300 '];
cmd = ['raspivid -o "' filename '" ' params.wc_raspivid_params ];
logmsg(cmd);
logmsg(['Started recording ' filename ' at ' datestr(now)]);
logmsg('Use Ctrl-C to stop recording');
system(cmd,false,'async' );
starttime = time;

function stop_recording(filename)
logmsg('Stopping raspivid');
system('pkill raspivid',false,'async');

% possibly need to wrap to mp4
% sudo apt-get install gpac

cmd = ['MP4Box -fps 30 -add "' filename '" "' filename '.mp4"'];
logmsg(['Trying: ' cmd]);
[stat,output ] = system(cmd,false,'async');
%or
% avconv -i ...h264 -vcodec copy ...mp4
% play video with omxplayer



