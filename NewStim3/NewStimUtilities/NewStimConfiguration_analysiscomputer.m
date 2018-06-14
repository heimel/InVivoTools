function NewStimConfiguration

% NewStimConfiguration.m
%
%  A user-specific configuration file which contains calibration code
%  for a specific machine and monitor.  Read each line of code and its comments
%  in order to set each parameter.
%

NewStimGlobals;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RemoteCommunication settings, part 1 of 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

remotecommglobals;
%  Is this a remote (slave, or, in other words, a stimulus) machine?
Remote_Comm_isremote = 1; %#ok<*NASGU>

Remote_Comm_enable = 1;  % enable remote communication?

Remote_Comm_eol = '\r';  % End of line, '\r' for MacOS9, '\n' for unix
Remote_Comm_method = 'filesystem';  % 'sockets' or 'filesystem'

% settings for Remote_Comm_method = 'filesystem'
% Remote_Comm_dir = '\\vs01.herseninstituut.knaw.nl\MVP\Shared\InVivo\'; % the local name of folder in which to write
Remote_Comm_dir = 'C:\Windows\Temp'; % the local name of folder in which to write
%   files for communication

% settings for Remote_Comm_method = 'sockets'
Remote_Comm_host = '152.16.225.216';
Remote_Comm_port = 1205;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RemoteCommunication settings, part 2 of 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if you are communicating with a remote computer via a filesystem,
% this section is important
% if this computer IS the remote computer, then this section is unimportant

Remote_Comm_remotearchitecture = 'unix'; % options are 'PC', 'Mac' (MacOS9), or 'unix' (Linux, MacOSX)
% the computer type of the remote machine you are talking to (not of THIS computer, necessarily)

Remote_Comm_localprefix = 'C:\Data'; % for example, 'Z:', 'z:', '/Users/Shared/myexperimentdir'
% the prefix to the shared directory on THIS computer

Remote_Comm_remoteprefix = '/mnt/THISHOSTNAME/data';
% the prefix to the same directory as viewed by the OTHER computer

% Example, suppose your "master" computer is a PC running Windows, and you
% want to use the directory 'C:\Users\VHLabRig2\remote'.  You share the 'C' drive
% (say with the "share" name 'VHLabRig2', and mount it on your stimulus computer
% (say this computer is a MacOSX computer).  When the MacOSX stimulus computer
% mounts the drive from your "master" computer, it will probably see it as
% '/Volumes/VHLabRig2/Users/VHLabRig2/remote'.
% So, on your master computer (the PC) you would set
% Remote_Comm_remotearchitecture = 'MacOSX';
% Remote_Comm_localprefix = 'C:';
% Remote_Comm_remoteprefix = '/Volumes/VHLabRig2';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monitor setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

StimWindowGlobals;
StimWindowMonitor = 0;  % use the given monitor, 0 is first
StimComputer = 1;       % is this a stimulus computer?
StimDebug = false;      % do you want to show stimuli in 640x480 window

StimWindowUseCLUTMapping = 0; % most users will say 0

MonitorWindowGlobals;
MonitorWindowMonitor = 0;  % use the given monitor, 0 is first
MonitorComputer = 0;       % does this computer have a monitor window?


if StimComputer&&haspsychtbox==2  % set up timing and monitor settings
    Screen('Preference','SecondsMultiplier',1.0);
    Screen('Preference','Backgrounding',1); 
else
    % set the current monitor dimensions for remote comm
    StimWindowRefresh = 60;
    StimWindowDepth = 8;
    StimWindowRect = [ 0 0 800 600 ];
end

% pixels_per_cm of the monitor in use
pixels_per_cm = 200/9.5;

NewStimViewingDistance = 15; %cm, 

NewStimTilt = 0; % degree tilt of screen on monitor

NewStimStimDelay = 6; % delay to give acquisition computers time to start

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Gamma correction settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GammaCorrectionTableGlobals;
GammaCorrectionEnable = 0;
LoadGammaCorrectionTable('gct_linear.txt');
%LoadGammaCorrectionTable('gct_HOSTNAME.txt');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Triggering/stimulus reporting settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  There are two options that can be used independently or simultaneously
%        * serial port triggering, via StimSerial (see "help StimSerial")
%            the start of a stimscript is indicated by a trigger on one serial port
%            the start of each stimulus is indicated by a trigger on another serial port
%        * stimulus reporting via parallel port using National Instruments PCI-DIO-96
%            the stimulus number is reported on the parallel port according
%                to Fitzpatrick lab protocol

% StimSerial, for sending messages over serial port in Mac OS9.
% Use portlist = serial('Ports') for a list of ports on your Mac.
% use system('setserial -bg /dev/ttyS*') on linux
% Available pins are 'dtr' (pin 4 of DE-9 serial port, or pin 20 of a DB-25
% port) and 'rts' (pin 7 of DE-9 port, or pin 4 of DB-25 port)

StimSerialGlobals; % see help file for description
StimSerialSerialPort = 1;          % do you want to enable this feature?
StimSerialScriptIn = '/dev/ttyS0';       % NewStim flips ScriptOutPin on this port when trial starts
StimSerialScriptInPin = 'dtr';       % flips this pin when trial starts
StimSerialScriptOut = '/dev/ttyS0';     % same
StimSerialScriptOutPin = 'dtr';       %
StimSerialStimIn = '/dev/ttyS0';  % NewStim flips DTR on this this port when individual stimuli start
StimSerialStimInPin = 'dtr';  % NewStim flips this pin when individual stimuli start
StimSerialStimOut = '/dev/ttyS0';% same
StimSerialStimOutPin = 'dtr';% same

% Display preferences
NSUseInitialSerialTrigger = 1;
NSUseStimSerialTrigger = 0;

StimDisplayOrderRemote = 0;
StimTriggerClear

%fitzTrigParams.triggerStimOnset = 1; % 0 means trigger BGpre instead of stim onset
%StimTriggerAdd('FitzTrig',fitzTrigParams);
%StimTriggerAdd('VHTrig',[]); % add Van Hooser lab triggering
