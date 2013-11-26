function b=StimTriggerAdd(TriggerType, parameters)


% STIMTRIGGERADD - Add a StimTrigger device to the NewStim package
%
%    B=STIMTRIGGERADD(TRIGGERTYPE, PARAMETERS)
%
%    Adds a new StimTrigger device to the list of devices called by StimTriggerAction.
%
%    TRIGGERTYPE is the type of the driver, e.g. 'FitzTrig'.  A valid
%       driver type is any device that can be configured by a call to
%       TRIGGERTYPE_STIMTRIGGERADD(TRIGGERTYPE, PARAMETERS)
% 
%
%    PARAMETERS - The parameters of the driver, only meaningful to the driver.
% 
%  See: STIMTRIGGERACTION

StimTriggerGlobals;

myDevStruct = struct('TriggerType',TriggerType,'parameters',parameters);

b = 1;

%try,
	eval([TriggerType '_StimTriggerAdd(TriggerType,parameters);']);
	if isempty(StimTriggerList),
		StimTriggerList = myDevStruct;
	else,
		StimTriggerList(end+1) = myDevStruct;
	end;
%catch,
%	b = 0;
%end;

