function [thetime,thecode]=GaiaTrig_StimTriggerAct(myDev,theaction,code,code2)

% GAIATRIG_STIMTRIGGERACTION Performs triggering action on windows pc with daq
%
%  Performs triggering action for gaia two photon setup
%
%    Port 0 is stimid, 0..255
%    Port 1 is stimtrigger (low bit, probably channel 30),
%              frame trigger (channel 31)
%              pre-time trigger (channel 32)
%

daq = myDev.parameters.daq;
thetime = [];
thecode = [];

switch theaction
    case 'Stim_beforeframe_trigger',
        %		DaqDOut(daq,1,0);
    case 'Stim_afterframe_trigger',
        %		DaqDOut(daq,1,2);
    case 'Stim_ONSET_trigger',
        dasbit(daq,1);
        logmsg(theaction);
        %		DaqDOut(daq,1,0);
    case 'Stim_BGpre_trigger',
        %		DaqDOut(daq,0,code);
    case 'Stim_BGpost_trigger',
        %		DaqDOut(daq,1,1);
    case 'Stim_OFFSET_trigger',
        dasbit(daq,0);
        %		DaqDOut(daq,1,1);
        logmsg(theaction);
    case 'Script_Start_trigger',
        dasbit(daq,1);
        WaitSecs(0.001);
        dasbit(daq,0);
        %		DaqDOut(daq,1,1);
        %		DaqDOut(daq,0,0);
        logmsg(theaction);
    case 'Script_Stop_trigger',
    case 'Trigger_Initialize',
        dasinit(daq);
        dasbit(daq,0)
        % DaqDOut(daq,1,1);
        % DaqDOut(daq,0,0);
        logmsg(theaction);
    case 'WaitActionCode',
    otherwise,
end

thetime = GetSecs;

%function DaqDOut(daq,port,code)
%PsychHID('SetReport',daq,2,4,uint8([0 port code]));
