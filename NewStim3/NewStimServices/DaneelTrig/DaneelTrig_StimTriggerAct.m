function [thetime,thecode]=DaneelTrig_StimTriggerAct(myDev,theaction,code,code2,code3)

% GAIATRIG_STIMTRIGGERACTION Performs triggering action on windows pc with daq
%
%  Performs triggering action for gaia two photon setup
%
%    Port 0 is stimid, 0..255
%    Port 1 is stimtrigger (low bit, probably channel 30),
%              frame trigger (channel 31)
%              pre-time trigger (channel 32)
%

if nargin<5
    code3 = [];
end

daq = myDev.parameters.daq;
pin = 1; % for laser
thetime = [];
thecode = [];

switch theaction
    case 'Stim_beforeframe_trigger',
        curtime = (code2-1)/60;
        if ~isempty(code3) && code3==1 && curtime>=0.1 && curtime<0.2
            dasbit(1,1);
            disp('Laser on');
        else
            dasbit(1,0);
            disp('Laser off')
            
        end
    case 'Stim_afterframe_trigger',
        %		DaqDOut(daq,1,2);
    case 'Stim_ONSET_trigger',
        %         dasbit(daq,1);
        %         logmsg(theaction);
        %		DaqDOut(daq,1,0);
    case 'Stim_BGpre_trigger',
        %		DaqDOut(daq,0,code);
    case 'Stim_BGpost_trigger',
        %		DaqDOut(daq,1,1);
    case 'Stim_OFFSET_trigger',
        %         dasbit(daq,0);
        %         %		DaqDOut(daq,1,1);
        %         logmsg(theaction);
    case 'Script_Start_trigger',
        %         dasbit(daq,1);
        %         WaitSecs(0.001);
        %         dasbit(daq,0);
        %		DaqDOut(daq,1,1);
        %		DaqDOut(daq,0,0);
        logmsg(theaction);
    case 'Script_Stop_trigger',
    case 'Trigger_Initialize',
        dasinit(daq);
        dasbit(pin,0)
        % DaqDOut(daq,1,1);
        % DaqDOut(daq,0,0);
        logmsg(theaction);
    case 'WaitActionCode',
    otherwise,
end

thetime = GetSecs;


%function DaqDOut(daq,port,code)
%PsychHID('SetReport',daq,2,4,uint8([0 port code]));
