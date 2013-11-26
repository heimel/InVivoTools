function str = NewStimMonitorsConfigureInterview

% NEWSTIMMONITORSCONFIGUREINTERVIEW - Configure Stim Monitors on NewStim
%
%  STR = NEWSTIMMONITORSCONFIGUREINTERVIEW
%

str = {};


NewStimGlobals;

StimWindowGlobals;
MonitorWindowGlobals;

if isempty(StimWindowMonitor), StimWindowMonitor = 0; end;
if isempty(StimWindowUseCLUTMapping), StimWindowUseCLUTMapping = 0; end;
if isempty(NewStimPeriodicStimUseDrawTexture), NewStimPeriodicStimUseDrawTexture = 1; end;

if isempty(MonitorComputer), MonitorComputer = 0; end;
if isempty(MonitorWindowMonitor), MonitorWindowMonitor = 0; end;

if isempty(StimWindowRefresh), StimWindowRefresh = 100; end;
if isempty(StimWindowDepth), StimWindowDepth = 8; end; % just make this equal to 8
if isempty(StimWindowRect), StimWindowRect = [0 0 800 600]; end;

if isempty(pixels_per_cm), pixels_per_cm = 20; end;


prompt={'Which monitor is StimWindow (0=first, 1=second, ...):',...
	'Does this computer have a 2nd monitor you want to use? (0/1) (probably 0):',...
	'If so, which monitor should we use as 2nd (0=first, 1=second, ...):', ...
	'What is the default frame refresh of your stim monitor (in Hz)? (60 or 100 is common):',...
	'What should the default size of your monitor be in pixels ([0 0 width height])? :', ...
	'How many pixels are there per cm on your monitor? (maybe 20?):'};

name='NewStim configuration: Stimulus Monitor';
numlines=1;
defaultanswer={num2str(StimWindowMonitor),...
	num2str(MonitorComputer), ...
	num2str(MonitorWindowMonitor), ...
	num2str(StimWindowRefresh),...
	mat2str(StimWindowRect), ...
	num2str(pixels_per_cm) ...
};
 
options.Resize='on';

answer = {};
while isempty(answer),
	answer=inputdlg(prompt,name,numlines,defaultanswer,options);
end;

