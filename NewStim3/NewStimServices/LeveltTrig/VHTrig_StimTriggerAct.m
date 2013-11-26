function [thetime,thecode]=VHTrig_StimTriggerAct(myDev,theaction,code,code2)

% VHTrig_STIMTRIGGERACTION Performs triggering action on Mac OSX with USB-1208FS
%
%  Performs triggering action for Van Hooser lab, Mac OS X with USB-1208FS
%
%    Port 0 is stimid, 0..255
%    Port 1 is stimtrigger (low bit, probably channel 30),
%              frame trigger (channel 31)
%              pre-time trigger (channel 32)
%

daq = myDev.parameters.daq;
thetime = []; thecode = [];

switch theaction,
	case 'Stim_beforeframe_trigger',
		DaqDOut(daq,1,0);
	case 'Stim_afterframe_trigger',
		DaqDOut(daq,1,2);
	case 'Stim_ONSET_trigger',
		DaqDOut(daq,1,0);
	case 'Stim_BGpre_trigger',
		DaqDOut(daq,0,code);
		DaqDOut(daq,1,4+1);  % the 4 sets the intrinsic trigger high
	case 'Stim_BGpost_trigger',
		DaqDOut(daq,1,1);
	case 'Stim_OFFSET_trigger',
		DaqDOut(daq,0,0);
		DaqDOut(daq,1,1);
	case 'Script_Start_trigger',
		DaqDOut(daq,1,1);
		DaqDOut(daq,0,0);
	case 'Script_Stop_trigger',
	case 'Trigger_Initialize',
		DaqDOut(daq,1,1);
		DaqDOut(daq,0,0);
	case 'WaitActionCode',
	otherwise,
end;

thetime = GetSecs;

function DaqDOut(daq,port,code)
PsychHID('SetReport',daq,2,4,uint8([0 port code]));
