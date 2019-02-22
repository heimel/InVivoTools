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
%   Legacy variables, not used anymore; these are now wrapped into NewStimService devices
% NSUseInitialSerialTrigger     : 0/1 use a serial port initial trigger
% NSUseStimSerialTrigger        : 0/1 use a serial port trigger before each stimulus

   
global pixels_per_cm %#ok<*NUSED> % pixels per cm of stimulus monitor

global NSUseInitialSerialTrigger  NSUseStimSerialTrigger  %

global NewStimStimList
global NewStimStimScriptList

global NS_PTBv  % psychtoolbox version, 0, 2, or 3

global StimDisplayOrderRemote

global NewStimViewingDistance;  % distance of subject to screen in cm

global NewStimTilt % in degrees

global NewStimStimDelay % time to allow acquisition and webcams to start
if isempty(NewStimStimDelay)
    NewStimStimDelay = 6; %
end

global StimNoBreak
if isempty(StimNoBreak)
    StimNoBreak = false;
end

global gNewStim % to replace other globals in the future

global NSUseInitialSerialContinuous

gNewStim.NewStim.pixels_per_cm = pixels_per_cm;
gNewStim.NewStim.UseInitialSerialTrigger = NSUseInitialSerialTrigger;
gNewStim.NewStim.UseStimSerialTrigger = NSUseStimSerialTrigger;
gNewStim.NewStim.StimList = NewStimStimList;
gNewStim.NewStim.ScriptList = NewStimStimScriptList;
gNewStim.NewStim.PTBv = NS_PTBv;
gNewStim.NewStim.DisplayOrderRemote = StimDisplayOrderRemote;
gNewStim.NewStim.ViewingDistance = NewStimViewingDistance;
gNewStim.NewStim.Tilt = NewStimTilt;
gNewStim.NewStim.StimDelay = NewStimStimDelay;
gNewStim.NSUseInitialSerialContinuous = NSUseInitialSerialContinuous;


