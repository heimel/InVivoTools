function [thetimes,thecodes]=StimTriggerAct(theaction, code, code2, code3)

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

if nargin<2
    code = []; %#ok<NASGU>
end
if nargin<3
    code2 = []; %#ok<NASGU>
end
if nargin<4
    code3 = [];
end

for i=1:length(StimTriggerList),
    try 
        trgcmd = ['[mytimes,mycodes]=' StimTriggerList(i).TriggerType '_StimTriggerAct(StimTriggerList(i),theaction,code,code2,code3);'];
        eval(trgcmd);
        thetimes = cat(1,thetimes,mytimes);
        thecodes = cat(1,thecodes,mycodes);
    catch
        logmsg(['Driver ' StimTriggerList(i).TriggerType ' did not activate successfully:' lasterr]);
        logmsg(trgcmd)
    end
end

if isempty(StimTriggerList)
    thetimes = GetSecs;
end

