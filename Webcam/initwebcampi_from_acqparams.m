function initwebcampi_from_acqparams(ready)
%INITWEBCAMPI_FROM_ACQPARAMS
% starts recording one long file while checking change in acqReady
%  based on INITWEBCAMPI_OPTO
%
% 2019, Alexander Heimel
%

if isoctave
    more off
    pkg load instrument-control
end

psychtoolbox_working = true;
try
   KbCheck;
catch
   % probably no graphical display possibility
   psychtoolbox_working = false;
   logmsg('Problem with KbCheck. No keyboard catching during script');
end   


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

logmsg('Set video parameters with params.wc_raspivid_params in processparams_local.m');

acqready_props_prev = dir(acqready);
if isempty(acqready_props_prev)
    acqready_props_prev = [];
    acqready_props_prev.datenum = datenum('01/01/2001 14:00');
end

logmsg('Finding serial port')
foundserial = false;
s1 = [];
d = dir('/dev/ttyUSB*');
if isempty(d)
    logmsg('No serial ports found in /dev/ttyUSB*');
    return
end
foundserial = true;
if length(d)==1
    devfolder = ['/dev/' d(1).name];
    logmsg(['Using unique serial port ' devfolder]);
else
    devfolder = StimSerialScriptIn;
    logmsg(['Using serial port ' devfolder ' set in NewStimConfiguration StimSerialScriptIn']);
end

% close port if accidently already open
%s1 = instrfind('Port',devfolder,'status','open' );
%if ~isempty(s1)
%    fclose(s1);
%end

s1 = serial(devfolder);

if ~isa(s1,'octave_serial') && ~isa(s1,'serial')
    logmsg('Could not find serial port of form /dev/ttyUSB*. Quitting');
    return
end
 if strcmp(devfolder,StimSerialScriptIn)
     switch StimSerialScriptInPin
        case 'dsr'
              pin = 'DataSetReady';
        case 'cts'
              pin = 'ClearToSend';
        otherwise
            errormsg(['Unknown pin ' StimSerialScriptInPin '. Change in NewStimConfiguration.']);
            return
     end
 else
     pin = 'DataSetReady';
 end
    
 logmsg(['Serial pin for script start: ' pin]);
    
 optopin = 'ClearToSend';
 logmsg(['Serial pin for optogenetics: ' optopin]);
    
 fopen(s1);



while 1

  logmsg(['Checking for change in ' acqready]);
  while 1 && ~ready
    acqready_props = dir(acqready);
    % give it some slacktime 0.0002 is about 16 s
    if ~isempty(acqready_props) && acqready_props.datenum > acqready_props_prev.datenum + 0.0002
        logmsg(['acqReady changed at ' datestr(acqready_props.datenum)]);
        %acqready_props
        acqready_props_prev = acqready_props;
        ready  = 1;
    else
        pause(0.05);
        pause(0.05);
    end
  end
  ready = 0;

  fid = fopen(acqready,'r');
  fgetl(fid); % pathSpec line
  datapath = fgetl(fid);
  fclose(fid);
  datapath = fullfile(datapath); % set right filesep
  logmsg(['Datapath set to ' datapath]);

  % for these store movie in actual datapath and not in parent folder
  if 0 && ~isempty(datapath) && any(datapath==filesep)
      recdatapath = datapath(1:find(datapath==filesep,1,'last'));
  else
      recdatapath = datapath;
  end


  [recstart,filename] = start_recording(recdatapath,params);

  manually_triggered = false;
  
  %Compatible with two versions of instrument-control
  if isfield(get(s1),'pinstatus') || isfield(get(s1),'PinStatus') % difference between matlab and octave
    new_instr_contr = 1;
  else
    new_instr_contr = 0;
    pin = lower(pin);
  end
    
  if new_instr_contr
    s2 = get(s1,'PinStatus');
    prev_cts = s2.(pin);
  else
    prev_cts = get(s1,pin);
  end
    
  org_cts = prev_cts;
  optogenetic_stimulation = false;
    
  datapath = 'initialpath_waiting_for_change';
  logmsg('Press q to quit. t for manual trigger');
  waiting_for_stop = false;
  while 1  % loop to find trigger
        
        if new_instr_contr
            s2 = get(s1,'PinStatus');
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
        
        if (cts(2)~=prev_cts(2) && cts(2)~=org_cts(2)) || manually_triggered  % i.e. changed and not same as original
            if waiting_for_stop
              logmsg('Received stop trigger');
              waiting_for_stop = false;
              break
            end
              
        
            stimstart =  (now - recstart)*24*3600; % in seconds
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
            
            acqparams_in = fullfile(datapath,'acqParams_in');
            if exist(acqparams_in,'file')
                acqinfo = loadStructArray(acqparams_in);
                duration = acqinfo.reps * 10; % each rep is 10s
                if ~isnan(duration)
                    logmsg(['Recording for '  num2str(duration) ' s.']);
                    break;
                    waiting_for_stop = false;
                else
                    logmsg('Recording until another trigger is received (duration = NaN)');
                    waiting_for_stop = true;
                end                
            else
              logmsg('Recording until another trigger is received (no acqparams_in file)');
              waiting_for_stop = true;
            end
            
            if manually_triggered
                manually_triggered = false;
                pause(0.1);
            end
            
        end
        prev_cts = cts;
        pause(0.001);
        if psychtoolbox_working 
            [keydown,~,keycode] = KbCheck;
            if keydown
                disp(['Key pressed. Key code ' find(keycode)]);
            end
            
            if keydown && (keycode(84) || keycode(29)) % t on PC and pi
                logmsg('Manually triggered');
                manually_triggered = true;
            end
            
            if keydown && (keycode(25) || keycode(81)) % 'q on pi and PC
                logmsg('Pressed q');
                fclose(s1);
                break
            end
        end
    end
    if ~waiting_for_stop 
       for t=1:ceil(duration)
           WaitSecs(1);
           disp([num2str(t) 's'])
           if psychtoolbox_working 
              [keydown,~,keycode] = KbCheck;
              if keydown && (keycode(25) || keycode(81)) % 'q on pi and PC
                  logmsg('Pressed q');
                break
              end
           end
        end
    end
    stop_recording(filename);
end % while


fclose(s1);

function [starttime,filename] = start_recording(datapath,params)
killraspivid;
mkdir(datapath);
filename = fullfile(datapath,['webcam_' host '_' subst_filechars(datestr(now,31)) '.h264'] );
if ~isunix % then definitely not a raspberry pi
    logmsg('Not a raspbeery pi. Not recording');
    starttime = now;
    return
end
cmd = ['raspivid -o "' filename '" ' params.wc_raspivid_params ];
logmsg(cmd);
logmsg(['Started recording ' filename ' at ' datestr(now)]);
logmsg('Use Ctrl-C to stop recording');
system(cmd,false,'async' );
starttime = now;

function stop_recording(filename)
logmsg('Stopping recording');
killraspivid;
%if isunix
%    %    system('pkill raspivid',false,'async');
%    system('pkill raspivid',true);
%    logmsg('Stopped recording');
%    % possibly need to wrap to mp4
%    % sudo apt-get install gpac
%    
%%    cmd = ['MP4Box -fps 30 -add "' filename '" "' filename '.mp4"'];
%%    logmsg(['Trying: ' cmd]);
%%    system(cmd,false,'async');
%    %or
%    % avconv -i ...h264 -vcodec copy ...mp4
%    % play video with omxplayer
%end

function killraspivid
system('pkill raspivid');
output = 'running';
timeout = 15; %s
while ~isempty(output) && timeout>0
  [status,output] = system('pgrep raspivid');
  pause(1);
  timeout = timeout - 1;
end
[status,output] = system('pgrep raspivid');
if ~isempty(output)
  logmsg('Unable to kill other raspivid');
end  
