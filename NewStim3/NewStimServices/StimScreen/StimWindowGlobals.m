%
% StimWindowGlobals
%
% This script declares all of the StimWindow global variables
%
%  StimWindowMonitor - The ID of the stimulus monitor (e.g., 0 for main screen)
%
%  StimComputer      - 0/1 is this a stimulus computer?
%
%  The following variables can be read by user programs but should not be set:
%
%  StimWindowDepth   - The pixel depth of the stimulus window.  The only
%                      supported depth at present is 8.
%
%  StimWindow        - The window pointer of the stimulus window, which covers
%                      the full screen.  If it does not exist, this variable is
%                      empty.
%  StimWindowRefresh - The refresh rate for the stimulus window.  Only
%                      computed _after_ the window is open.
%
%  StimWindowPreviousCLUT- The color table that was present when StimWindow was opened by ShowStimScreen
%
%  StimWindowUseCLUTMapping - Use the special PsychImaging mode for Color
%  Table animation
%
%
%  See also:  SHOWSTIMSCREEN, CLOSESTIMSCREEN
%

global StimWindow StimWindowMonitor StimWindowDepth StimWindowRefresh StimWindowRect StimComputer StimScreenBG StimWindowPreviousCLUT StimWindowUseCLUTMapping StimDebug 
if isempty(StimDebug) 
    StimDebug = false;
end 

global gNewStim % to replace other globals in the future
gNewStim.StimWindow.window = StimWindow; 
gNewStim.StimWindow.monitor = StimWindowMonitor; 
gNewStim.StimWindow.depth = StimWindowDepth;
gNewStim.StimWindow.refresh = StimWindowRefresh;
gNewStim.StimWindow.rect = StimWindowRect;
gNewStim.StimWindow.computer = StimComputer;
gNewStim.StimWindow.bg = StimScreenBG;
gNewStim.StimWindow.previousclut = StimWindowPreviousCLUT;
gNewStim.StimWindow.useclutmapping = StimWindowUseCLUTMapping;
gNewStim.StimWindow.debug = StimDebug;   % replaced in InVivoTools






