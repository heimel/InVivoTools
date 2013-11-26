% NewStimGlobals.m
%
% Global variables, as set in NewStimCalibrate
%
% pixels_per_cm           : pixels per cm of stimulus monitor
% 
% NewStimStimList         : a list of all supported stimulus objects
% NewStimStimScriptList   : a list of all supported stimscript objects
%
% StimDisplayOrderRemote  : I do not remember what this is for
%
% NS_PTBvers              : The Psychophysics toolbox version: 0(none),2(2),3(3)
% 
%
%   Legacy variables, not used anymore; these are now wrapped into NewStimService devices
% NSUseInitialSerialTrigger     : 0/1 use a serial port initial trigger
% NSUseStimSerialTrigger        : 0/1 use a serial port trigger before each stimulus
% NSUsePCIDIO96Trigger          : 0/1 use a Nat. Instruments PCI DIO 96 card for stim reporting


   % do not set values here
   
global pixels_per_cm;

global NSUseInitialSerialTrigger NSUseStimSerialTrigger NSUsePCIDIO96Trigger NSUsePCIDIO96InputTrigger % these are old

global NewStimStimList
global NewStimStimScriptList

global NewStimPeriodicStimUseDrawTexture

global NS_PTBv  % psychtoolbox version, 0, 2, or 3

global StimDisplayOrderRemote

% distance of subject to screen in cm
global NewStimViewingDistance; %#ok<NUSED> 

global NewStimTilt % in degrees


