function CloseStimScreen
StimWindowGlobals

if ~isempty(StimWindow) %#ok<*NODEF>
    temp = StimWindow;
    StimWindow = []; %#ok<*NASGU>
    try
        Screen(temp,'close');
    catch me
        logmsg(me.message);
    end
else
    StimWindow = [];
end

if ~isempty(StimWindowPreviousCLUT)
    try
        Screen('LoadNormalizedGammaTable',StimWindowMonitor,StimWindowPreviousCLUT);
    catch me
        logmsg(me.message);
    end
    StimWindowPreviousCLUT = [];
end
CloseStimScreenBlender

ShowCursor;

if gNewStim.StimWindow.debug
    NewStimConfiguration; % to reset StimWindow settings
end