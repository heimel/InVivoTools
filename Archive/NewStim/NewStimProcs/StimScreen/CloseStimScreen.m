function CloseStimScreen

StimWindowGlobals

if ~isempty(StimWindow) %#ok<NODEF>
    if isunix
        try
            % LoadClut only works for PTB3, for PTB2 command is SetClut
            Screen('LoadClut',StimWindow,repmat((0:255)',1,3));
        catch
            disp('LoadClut failed');
        end
    end
	temp = StimWindow;
	StimWindow = []; %#ok<NASGU>
	Screen(temp,'close');
else
	StimWindow = []; %#ok<NASGU>
end;
