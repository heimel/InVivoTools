function CloseStimScreen
StimWindowGlobals

if ~isempty(StimWindow),
	temp = StimWindow;
	StimWindow = [];
	try
		Screen(temp,'close');
	end;
else
	StimWindow = [];
end

if ~isempty(StimWindowPreviousCLUT),
	Screen('LoadNormalizedGammaTable',StimWindowMonitor,StimWindowPreviousCLUT);
	StimWindowPreviousCLUT = [];
end;
CloseStimScreenBlender

ShowCursor;

if gNewStim.StimWindow.debug
    NewStimConfiguration; % to reset StimWindow settings
end