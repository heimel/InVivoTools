 function StimTriggerClear

% STIMTRIGGERCLEAR - clear StimTrigger list
%
%   Empties the StimTriggerList; must be called before recalibrating
%
%

StimTriggerGlobals;
StimTriggerClose;
StimTriggerList = [];
