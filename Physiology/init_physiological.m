function init_physiological_measurement(parameter_file_name)
%init_physiological_measurement enter_parameter_file_name_here  
% 
%   Initialization for Physiological measurements using a Data-acquisition
%   card in MatLab. This function waits for an update in the file acqReady,
%   which triggers the program. There is a pop-up window with a push-button
%   to escape the while loop.
% 
%   If no value is added to init_physiological_measurement to load the
%   according measurent and vendor specific configuration, a default
%   configuration will be used -> daq_parameters_mcc_USBmic.m
%
%   Physiological measurement scripts are written to be part of the
%   InVivoToolbox and cannot operate stand alone (except for some
%   simulations)
%
%   See also data_acquis_daq(), daq_parameters_xxx() for more information
%   about functionallity and how to address.
%
%   For calibration see either calibrate_mcc() or calibrate_mic()
%
%   -> Remove temporarily startup code! <-
%
%    
%   (c) 2016, Simon Lansbergen.
% 

%-------------------------------------------------------------------------%
% Initialisation
% clear all       % Clear all variables in workspace
close all       % Close all current windows with figures (plots)
clc             % Clear Command window
echo off        % No echoing of commands lines in script/function files
%-------------------------------------------------------------------------%


% Checks whether there is an input, otherwise sets parameter file to
% current setup -> daq_parameters_mcc_USBmic. Default configuration can be found
% in daq_parameters.
if nargin<1
    parameter_file_name = 'daq_parameters_mcc_USBmic';
end

%
%
% temp startup
host('jander');
experiment test;

% get global communication variables.
remotecommglobals;
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
% cd(theDir); % refresh file directory

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
        data_acquis_daq(parameter_file_name); % start acquisition session
    else
        pause(0.3);
        logmsg('Checking for acqReady change...hit button or press Ctrl-C to interrupt.');
    end
end

disp(' ');disp(' ');logmsg(' *** Acquisition loop terminated by user ***');

% checks whether the Analog Input object is still active/open or just not
% properly closed.
% if exist ai var
% stop(ai);       % Stops (all active processes on) analog input object
% delete(ai);     % Deletes analog input object
% clear ai        % Removes analog input object from workspace
% end


end 