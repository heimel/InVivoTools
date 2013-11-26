function StimTriggerOpen

% StimTriggerOpen -Initializes devices for stim triggering
%
%  STIMTRIGGEROPEN
%
%    Asks all StimTrigger devices to open and initialize for use.

StimTriggerGlobals;

for i=1:length(StimTriggerList),
        try,
                eval([StimTriggerList(i).TriggerType '_StimTriggerOpen(StimTriggerList(i));']);
        catch,
                warning(['Device ' StimTriggerList(i).TriggerType ' did not open successfully:' lasterr]);
        end;
end;

