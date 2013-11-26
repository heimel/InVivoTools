function StimTriggerClose

% STIMTRIGGERCLOSE - Close all StimTrigger devices
%
%   STIMTRIGGERCLOSE
%
%  Asks all open StimTrigger devices to close/release any open ports.

StimTriggerGlobals;

for i=1:length(StimTriggerList),
        try,
		eval([StimTriggerList(i).TriggerType '_StimTriggerClose(StimTriggerList(i));']);
	catch,
		warning(['Device ' StimTriggerList(i).TriggerType ' did not close successfully:' lasterr]);
	end;
end;

