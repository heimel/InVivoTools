function [thetimes,thecodes]=StimTriggerAct(theaction, code, code2)

% STIMTRIGGERACTION - Activate a StimTrigger
%
%   [TIMES,CODES]=STIMTRIGGERACT(THEACTION, [CODE])
%
%     Cycles through the StimTrigger list of devices (those added by
%   STIMTRIGGERADD) and calls
%   TriggerType_StimTriggerAction(myDevStruct,theaction,thecode);
%
%   Known actions can vary by device but should include:
%
%        'Script_ONSET_trigger'
%        'Stim_BGpre_trigger'
%        'Stim_ONSET_trigger'
%	 'Stim_frame_trigger'
%        'Stim_OFFSET_trigger'
%        'Stim_BGpost_trigger'
%        'Script_OFFSET_trigger


StimTriggerGlobals;

thetimes = []; 
thecodes = [];

if nargin<2, code = []; end;
if nargin<3, code2 = []; end;

for i=1:length(StimTriggerList),
        try,
                eval(['[mytimes,mycodes]=' StimTriggerList(i).TriggerType '_StimTriggerAct(StimTriggerList(i),theaction,code,code2);']);
				thetimes = cat(1,thetimes,mytimes);
				thecodes = cat(1,thecodes,mycodes);
        catch,
                warning(['Driver ' StimTriggerList(i).TriggerType ' did not activate successfully:' lasterr]);
        end;
end;

if isempty(StimTriggerList), thetimes = GetSecs; end;
