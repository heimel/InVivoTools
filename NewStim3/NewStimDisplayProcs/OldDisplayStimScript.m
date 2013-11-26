function [MTI,startTrig] = DisplayStimScript(stimScript, MTI, priorit,abtable)
%
%  [MTI,STARTRIG] = DISPLAYSTIMSCRIPT (STIMSCRIPT, MTI, PRIORIT, ABORTABLE)
%
%  DisplayStimScript draws the stimScript to the screen, and gives the record of stimulus
%  presentation times in MTI.  The time of the first frame is given in STARTTRIG.  It
%  takes as arguments the STIMSCRIPT to be displayed, and also a precomputed MTI record.
%
%  If PRIORIT is specified and is not empty, drawing is run with that priority.
%  Otherwise, the priority is determined automatically.
%
%  If ABORTABLE is not given or is 1, then the script can be aborted by pressing any key
%  on the stimulus computer keyboard.  IF ABORTABLE is 0 the script is not abortable.  One may
%  want to run without the possibility of an abort to ensure the most reliable timing between
%  stimuli.
%
%  Bugs:  The system will hang if one tries to show a stimulus with clipping on the first
%  run after booting at max priority.  As a work-around, either first run a script without
%  any clipping or run the stimulus through one time at priority 0.
%  I do not know why this happens.
%
%  Sound sometimes has errors if it is not run at priority 0.
%
%
%

NewStimGlobals;
StimWindowGlobals;

if nargin<2, MTI = DisplayTiming(stimScript); end;
prioritylevel = MaxPriority(StimWindowMonitor,'WaitBlanking','SetClut','GetSecs');
if nargin>=3,
	if ~isempty(priorit),
		prioritylevel = priorit;
	else, % set priority more carefully
		for i=1:length(MTI),
			if strcmp(MTI{i}.ds.displayType,'Sound'), prioritylevel = 0; break; end;
		end;
	end;
end;
abortable = 1;
if nargin>=4, abortable = abtable; end;

numstims = numStims(stimScript);
	
% preferences

if ~isloaded(stimScript), error('Cannot display unloaded stimulus'); end;

	HideCursor;
	StimSerialGlobals;
	StimPCIDIO96Globals;
	ShowStimScreen	
	
	l = length(MTI);

	if NSUseInitialSerialTrigger&StimSerialSerialPort, % set serial ports high initially
		StimSerial('dtr',StimSerialScript,1);
	end;
	if NSUseStimSerialTrigger&StimSerialSerialPort, 
		StimSerial('dtr',StimSerialStim,1);
	end;

	% now build the rush loop
	%  the loop conditionally activates triggers so it is a bit hard to read

	%  start everything on a waitblanking
	startTrig = 0;
	loop = { 		'screen(StimWindow,''WaitBlanking'');' };
	if NSUseInitialSerialTrigger&StimSerialSerialPort,
		loop = cat(1,loop,{'StimSerial(''dtr'',StimSerialScript,0);'});
	end;
	loop = cat(1,loop,{'startTrig = getsecs;'});
	if NSUseStimSerialTrigger&StimSerialSerialPort,
		loop = cat(1,loop,{'StimSerial(''dtr'',StimSerialScript,1);'});
	end;
	
	if NSUsePCIDIO96Trigger,
		loop = cat(1,loop,{'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInCPort,NSPCIDIO96.CEDeventtriggeron);'});
	end;
	StimCodeA = 0;
	StimCodeB = 0;
	
	% strings to include for PCIDIO96Trigger
	PCIDIO96eachstimafterbg = {'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInAPort,StimCodeA+NSPCIDIO96.CEDstimtrigger);'
					'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqUserInPort,NSPCIDIO96.sandvtrigger);'
					'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInAPort,StimCodeA);'
					'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInCPort,NSPCIDIO96.CEDeventtriggeroff);' };
	PCIDIO96beforeframe = {'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqUserInPort,NSPCIDIO96.vontrigger);'};
	PCIDIO96afterframe = {'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqUserInPort,NSPCIDIO96.vofftrigger);'};
	PCIDIO96beforestim = {
			'StimCodeB=bitand(MTI{i}.stimid,255);StimCodeA=bitshift(bitand(MTI{i}.stimid,65280),-8);'
			'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInBPort,StimCodeB);'
	};
	PCIDIO96afterstim = {
		'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInCPort,NSPCIDIO96.CEDeventtriggeron);'
		'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInAPort,0);'   % clear port, event needs transition.
		'DIG_Out_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.CEDdigitalInBPort,0);'    % clear both ports, just for symmetry. 
	};

	
	% now begin main loop, checking each displaystruct to see what type it is and displaying it
	loop = cat(1,loop, { 'screen(StimWindow,''WaitBlanking'');'});
	innerloop = {};
	if ~abortable, innerloop = cat(1,innerloop, {    'for i=1:l,' }); end;
	innerloop =cat(1,innerloop,{ 	'rect = screen(MTI{i}.ds.offscreen(1),''Rect'');' });
	innerloop = cat(1,innerloop, {  % wait for trigger
		'if NSUsePCIDIO96InputTrigger,'
			'fprintf(''waiting for 2p gobit>'');'
				'Trigger_Response = 0;'
				'while (Trigger_Response==0)&~KbCheck,'
					'[PrairieByteIn,error]=DIG_In_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.PrairieOutputPort);'
					'Trigger_Response = bitget(PrairieByteIn,1);'  % 1 is go bit
				'end;'
		'end;'});
		if NSUseStimSerialTrigger&StimSerialSerialPort, % if triggering every stim then trigger
			innerloop = cat(1,innerloop,{'StimSerial(''dtr'',StimSerialStim,0);getsecs;' 
			'StimSerial(''dtr'',StimSerialStim,1);'});
		end;
		if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96beforestim); end;

	% now show the stims
	innerloop = cat(1,innerloop, {
		'if strcmp(MTI{i}.ds.displayType,''CLUTanim''),'
			'if MTI{i}.preBGframes>0,'
				'screen(StimWindow,''FillRect'',0);'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'if (MTI{i}.ds.makeClip), screen(StimWindow,''SetDrawingRegion'',MTI{i}.ds.clipRect,MTI{i}.ds.makeClip-1); end;'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'screen(''CopyWindow'',MTI{i}.ds.offscreen,StimWindow,rect, MTI{i}.df.rect,''srcCopy'');'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'
			'else,'
				'screen(StimWindow,''FillRect'',0);'
				'if (MTI{i}.ds.makeClip), screen(StimWindow,''SetDrawingRegion'',MTI{i}.ds.clipRect,MTI{i}.ds.makeClip-1); end;'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'screen(''CopyWindow'',MTI{i}.ds.offscreen,StimWindow,rect, MTI{i}.df.rect,''srcCopy'');'
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96eachstimafterbg); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.startStopTimes(2) = GetSecs;'
			'SCREEN(StimWindow,''SetClut'',MTI{i}.ds.clut{MTI{i}.df.frames(1)});' });
			if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.frameTimes(1) = GetSecs;'
			'for frameNum=2:length(MTI{i}.df.frames),'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(frameNum-1));' });
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96beforeframe); end;
	innerloop = cat(1,innerloop, {
				'SCREEN(StimWindow,''SetClut'',MTI{i}.ds.clut{MTI{i}.df.frames(frameNum)});'
				'MTI{i}.frameTimes(frameNum) = GetSecs;'});
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'end;'
			'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(end));'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {
			'if (MTI{i}.postBGframes>0)|(i==l),'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
			'if (MTI{i}.ds.makeClip), screen(StimWindow,''SetDrawingRegion'',StimWindowRect); end;'
		'elseif strcmp(MTI{i}.ds.displayType,''Movie''),'
			'if MTI{i}.preBGframes>0,'
				'screen(StimWindow,''FillRect'',0);'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'			
			'else,'
				'screen(StimWindow,''FillRect'',0);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96eachstimafterbg); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.startStopTimes(2) = GetSecs;'	
			'SCREEN(StimWindow,''SetClut'',MTI{i}.ds.clut);'
			'if (MTI{i}.ds.makeClip), screen(StimWindow,''SetDrawingRegion'',MTI{i}.ds.clipRect,MTI{i}.ds.makeClip-1); end;'
			'SCREEN(''CopyWindow'',MTI{i}.ds.offscreen(MTI{i}.df.frames(1)),StimWindow,rect, MTI{i}.df.rect,''srcCopyQuickly'');'});
			if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.frameTimes(1) = GetSecs;'
			'for frameNum=2:length(MTI{i}.df.frames);'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(frameNum-1));'});
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96beforeframe); end;
	innerloop = cat(1,innerloop, {
				'SCREEN(''CopyWindow'',MTI{i}.ds.offscreen(MTI{i}.df.frames(frameNum)),StimWindow,rect, MTI{i}.df.rect,''srcCopyQuickly'');'});
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
				'MTI{i}.frameTimes(frameNum) = GetSecs;'
			'end;'
			'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(end));'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {			
			'if (MTI{i}.postBGframes>0)|(i==l),'
				'screen(StimWindow,''FillRect'',0);'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'screen(StimWindow,''FillRect'',0);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
			'if (MTI{i}.ds.makeClip), screen(StimWindow,''SetDrawingRegion'',StimWindowRect); end;'
		'elseif strcmp(MTI{i}.ds.displayType,''Sound''),'
			'Snd(''Open'');'
			'if MTI{i}.preBGframes>=0,'
				'screen(StimWindow,''FillRect'',0);'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'			
			'else,'
				'MTI{i}.startStopTimes(1) = GetSecs;'
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96eachstimafterbg); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.startStopTimes(2) = GetSecs;'	
			'Snd(''Play'',MTI{i}.ds.userfield.sound,MTI{i}.ds.userfield.rate);'
			}  );
			if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.frameTimes(1) = GetSecs;'
			'Snd(''Wait'');' });
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {			
			'if (MTI{i}.postBGframes>0)|(i==l),'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
			'Snd(''Close'');'
		'elseif strcmp(MTI{i}.ds.displayType,''custom''),'
			'if MTI{i}.preBGframes>0,'
				'screen(StimWindow,''FillRect'',0);'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'
			'else,'
				'MTI{i}.startStopTimes(1) = GetSecs;'
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96eachstimafterbg); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.startStopTimes(2) = GetSecs;'
			'done=0;stamp=0;info=[];stampNum=1;'
			'while(done==0),'
				'eval([''[done,stamp,info]='' MTI{i}.ds.displayProc ''(info,StimWindow,MTI{i}.ds,MTI{i}.df);'']);'
				'if stamp==1, '});
					if NSUsePCIDIO96Trigger,innerloop=cat(1,innerloop,PCIDIO96afterframe);end;
	innerloop = cat(1,innerloop, {
					'MTI{i}.frameTimes(stampNum)=GetSecs; stampNum=stampNum+1;waitsecs(1/10000);'
					'end;'});
					if NSUsePCIDIO96Trigger,innerloop=cat(1,innerloop,PCIDIO96beforeframe);end;
	innerloop = cat(1,innerloop, {					
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {
			'if (MTI{i}.postBGframes>0)|(i==l),'
				'screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'SCREEN(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
		'end;'});
	if ~abortable,
		innerloop = cat(1,innerloop, {
	'end;'}); % end loop over stims
	end;

    SCREEN('Screens'); try, Snd('Open'); Snd('Close'); end;
	if ~abortable,
		loop = cat(1,loop,innerloop);
    	RUSH(loop,prioritylevel);
	else,
		fprintf([int2str(l) ' stims to run, ' int2str(numstims) ' stims in script.\n']);
		RUSH(loop,prioritylevel);
		for i=1:l,
			RUSH(innerloop,prioritylevel);
			if KbCheck, break; end;
			if mod(i,20)==0, fprintf(['Just finished stim ' int2str(i) ' of ' int2str(l) '.\n']); end;
			if mod(i,numstims)==0, fprintf(['Just finished trial ' int2str(i/numstims) ' of ' int2str(l/numstims) '.\n']); end;
		end;
	end;

	if 0,
		bigchar = [];   % for debugging
		for i=1:length(loop),
			bigchar = [ bigchar loop{i}];
		end;
		eval(bigchar);
	end;
	ShowCursor;
