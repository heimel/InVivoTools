function init_getvideo
%INIT_GETVIDEO.m initialization script for video acquisition. 
%Runs main_getvideo() in a loop. No input.
%-------------------------------------------------------------------------%
%     
%   Initialization script for video acquisition using Basler Ace 640-90um
%   USB 3.0 CCD camera and NI 6008 USB data acquisition board. 
%
%   Written exclusivly for InVivoTools-toolbox and the above mentioned 
%   hardware. Matlab 32-bits mandatory for trigger setup using the NI DAQ.
%
%   The script gets the according dirtectories by running remotecommglobals()
%   from the InVivoTools toolbox, which setups communication between 
%   stimulation, acquisition and triggering systems.
%	
%	Always check for the latest grabavi.exe with the date of grabavi.cpp, 
%	otherwise complile grabavi.exe from latest cpp version.
%
%   Used scripts:
%       remotecommglobals()
%       main_getvideo()
%
%
%
%   Last edited 19-5-2016. SL
%
%   Tested up to acquisistion trigger - no simulation except triggering
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% Initialisation
clear all       % Clear all variables in workspace
close all       % Close all current windows with figures (plots)
clc             % Clear Command window
%-------------------------------------------------------------------------%

% get global communication variables.
NewStimConfiguration;
remotecommglobals;

% SIMULATION -> REMOVE WHEN USING
% Remote_Comm_dir = fullfile('c:\temp');     % <- REMOVE

acqready = fullfile(Remote_Comm_dir,'acqReady');

% check for existance save directory
theDir = Remote_Comm_dir;
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


% why? -> purpose for my code?
acqready_props_prev = dir(acqready);
if isempty(acqready_props_prev)
    acqready_props_prev = [];
    acqready_props_prev.datenum = datenum('2001-01-01');
end

% set and create window for button -> uicontrol
button_window=figure;
set(button_window,'Position',[100 100 150 100])

% create push button
push_button = uicontrol(button_window,'Style', 'PushButton', ...
                    'String', 'Break', ...
                    'Position', [50 20 50 20],...
                    'Callback', 'delete(gcbf)');

% create text in window
text = uicontrol(button_window,'Style', 'text',...
        'position', [10 70 150 30],...
        'String','hit button to break from acquisition-loop');
                

% while loop which check for a change in acqReady
logmsg('Checking for acqReady change');
while (ishandle(push_button))     % needs control-C or push button to exit
    acqready_props = dir(acqready);
    if ~isempty(acqready_props) && acqready_props.datenum > acqready_props_prev.datenum
        logmsg('acqReady changed');
        acqready_props_prev = acqready_props;
        
        % Start acquisition session based on remotecommglobals() input
        main_getvideo(); % --> start video acquisition session      
        
    else
        pause(0.3);
        logmsg('Checking for acqReady change...hit button or press Ctrl-C to interrupt.');
    end
end

disp(' ');disp(' ');logmsg(' *** Video acquisition loop terminated by user ***');


end
