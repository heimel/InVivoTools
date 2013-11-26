function VHTrig_StimTriggerReset

% VHTRIG_STIMTRIGGERRESET - Call this function to reset VHTRIGs and force them to reopen

StimTriggerGlobals;

for i=1:length(StimTriggerList),
	if strcmp(StimTriggerList(i).TriggerType,'VHTrig')
		DaqReset([]); clear PsychHID; pause(2); % this resets the device
		if isfield(StimTriggerList(i).parameters,'daq'),
			StimTriggerList(i).parameters = rmfield(StimTriggerList(i).parameters,'daq');
		end;
		VHTrig_StimTriggerOpen(StimTriggerList(i));
	end;
end;
