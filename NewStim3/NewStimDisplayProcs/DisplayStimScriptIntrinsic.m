function [MTI,startTrig] = DisplayStimScriptIntrinsic(stimScript, MTI, priorit, ISstim)
%
%  [MTI,STARTRIG] = DISPLAYSTIMSCRIPTINTRINSIC(STIMSCRIPT, MTI, PRIORIT, ISIstims)
%
%  DisplayStimScript draws the stimScript to the screen, and gives the record of stimulus
%  presentation times in MTI.  The time of the first frame is given in STARTTRIG.  It
%  takes as arguments the STIMSCRIPT to be displayed, and also a precomputed MTI record.
%
%  The main difference between DISPLAYSTIMSCRIPTINTRINSIC and DISPLAYSTIMSCRIPT is that it
%  is assumed that some other device is the master and is picking stimulus display order.
%  Therefore, the script STIMSCRIPT should have display order equal to 1:1:numStims(STIMSCRIPT).
%
%  If PRIORIT is specified and is not empty, drawing is run with that priority.
%  Otherwise, the priority is determined automatically.
%
%  If ISstims is not empty, then ISstims(i) will be displayed between the ith stimulus commands
%  from the imaging system.  If length(ISstims) is exceeded, then the 'interstimulus stimulus'
%  to be shown will be selected from the beginning of the list and the list will be run in order
%  again.
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
prioritylevel = MaxPriority(StimWindowMonitor,'WaitBlanking','SetClut','GetSecs','KbCheck');
if nargin>=3,
	if ~isempty(priorit),
		prioritylevel = priorit;
	else, % set priority more carefully
		for i=1:length(MTI),
			if strcmp(MTI{i}.ds.displayType,'Sound'), prioritylevel = 0; break; end;
		end;
	end;
end;
if nargin<4, ISstim = []; end;
abortable = 1;

numstims = numStims(stimScript);
if ISstim<0|ISstim>numstims, error(['ISstim must be in 1..numStims (' int2str(numstims) ' in this script).']); end;

MTIin = MTI; MTI = {};

% preferences

if ~isloaded(stimScript), error('Cannot display unloaded stimulus'); end;

	HideCursor;
	StimSerialGlobals;
	StimPCIDIO96Globals;
	ShowStimScreen

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
	loop = { 		'Screen(StimWindow,''WaitBlanking'');' };
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

	ISstimgo = 0; ISstimnum=1;i=1;
	% now begin main loop, checking each displaystruct to see what type it is and displaying it
	loop = cat(1,loop, { 'Screen(StimWindow,''WaitBlanking'');'});
	innerloop = {};
	innerloop=cat(1,innerloop,{
	'if ISstimgo==1, stimpos = mod(ISstimnum,length(ISstim)); if stimpos==0,stimpos=length(ISstim);end; stimid=ISstim(stimpos);fprintf(''Running ''''interstimulus stim'''' %4d'', stimid);'
	'else,'
				'fprintf(''waiting for gobit>'');'
				'VDAQ_Response = 0;'
				'while (VDAQ_Response==0)&~KbCheck,'
					'[VdaqUserBByteIn,error]=DIG_In_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqUserOutBPort);'
					'VDAQ_Response = bitget(VdaqUserBByteIn,7);'  % 7 is go bit
				'end;'});
	innerloop = cat(1,innerloop,{'[VdaqStimByteIn, error] = DIG_In_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqStimOutPort);'
			'stimid = double(bitget(VdaqStimByteIn,7)*1+bitget(VdaqStimByteIn,6)*2+bitget(VdaqStimByteIn,5)*4+bitget(VdaqStimByteIn,4)*8+bitget(VdaqStimByteIn,3)*16);'
			'fprintf(''Got Go Bit>%4d'',stimid);tic;'
			'if stimid<1|stimid>length(MTIin), '
				'[VdaqStimByteIn, error] = DIG_In_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqStimOutPort);'
				'stimid = bitget(VdaqStimByteIn,7)*1+bitget(VdaqStimByteIn,6)*2+bitget(VdaqStimByteIn,5)*4+bitget(VdaqStimByteIn,4)*8+bitget(VdaqStimByteIn,3)*16;'
				'fprintf(''%4d'',stimid);'
				'ShowCursor; fprintf([''ERROR: Requested stimid is out of range 1.. '' int2str(numstims) ''.'']); error([''Requested stim is out of range.'']); end;'
	'end;'
			'MTI{i}=MTIin{stimid};'
			});
	innerloop =cat(1,innerloop,{ 	'rect = Screen(MTI{i}.ds.offscreen(1),''Rect'');' });
		if NSUseStimSerialTrigger&StimSerialSerialPort, % if triggering every stim then trigger
			innerloop = cat(1,innerloop,{'StimSerial(''dtr'',StimSerialStim,0);getsecs;' 
			'StimSerial(''dtr'',StimSerialStim,1);'});
		end;
		if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96beforestim); end;

	% now show the stims
	innerloop = cat(1,innerloop, {
		'if strcmp(MTI{i}.ds.displayType,''CLUTanim''),'
			'if MTI{i}.preBGframes>=0,'
				'Screen(StimWindow,''FillRect'',0);'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'if (MTI{i}.ds.makeClip), Screen(StimWindow,''SetDrawingRegion'',MTI{i}.ds.clipRect,MTI{i}.ds.makeClip-1); end;'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'Screen(''CopyWindow'',MTI{i}.ds.offscreen,StimWindow,rect, MTI{i}.df.rect,''srcCopy'');'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'
			'else,'
				'if (MTI{i}.ds.makeClip), Screen(StimWindow,''SetDrawingRegion'',MTI{i}.ds.clipRect,MTI{i}.ds.makeClip-1); end;'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'Screen(''CopyWindow'',MTI{i}.ds.offscreen,StimWindow,rect, MTI{i}.df.rect,''srcCopy'');'
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96eachstimafterbg); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.startStopTimes(2) = GetSecs;'
			'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut{MTI{i}.df.frames(1)});' });
			if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.frameTimes(1) = GetSecs;'
			'for frameNum=2:length(MTI{i}.df.frames);'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(frameNum-1));' });
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96beforeframe); end;
	innerloop = cat(1,innerloop, {
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut{MTI{i}.df.frames(frameNum)});'
				'MTI{i}.frameTimes(frameNum) = GetSecs;'});
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'end;'
			'Screen(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(end));'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {
			'if (MTI{i}.postBGframes>=0),'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
			'if (MTI{i}.ds.makeClip), Screen(StimWindow,''SetDrawingRegion'',StimWindowRect); end;'
		'elseif strcmp(MTI{i}.ds.displayType,''Movie''),'
			'if MTI{i}.preBGframes>=0,'
				'Screen(StimWindow,''FillRect'',0);'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'			
			'else,'
				'MTI{i}.startStopTimes(1) = GetSecs;'
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96eachstimafterbg); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.startStopTimes(2) = GetSecs;'	
			'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut);'
			'if (MTI{i}.ds.makeClip), Screen(StimWindow,''SetDrawingRegion'',MTI{i}.ds.clipRect,MTI{i}.ds.makeClip-1); end;'
			'Screen(''CopyWindow'',MTI{i}.ds.offscreen(MTI{i}.df.frames(1)),StimWindow,rect, MTI{i}.df.rect,''srcCopyQuickly'');'});
			if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
			'MTI{i}.frameTimes(1) = GetSecs;'
			'for frameNum=2:length(MTI{i}.df.frames);'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(frameNum-1));'});
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96beforeframe); end;
	innerloop = cat(1,innerloop, {
				'Screen(''CopyWindow'',MTI{i}.ds.offscreen(MTI{i}.df.frames(frameNum)),StimWindow,rect, MTI{i}.df.rect,''srcCopyQuickly'');'});
				if NSUsePCIDIO96Trigger, innerloop = cat(1,innerloop,PCIDIO96afterframe); end;
	innerloop = cat(1,innerloop, {
				'MTI{i}.frameTimes(frameNum) = GetSecs;'
			'end;'
			'Screen(StimWindow,''WaitBlanking'',MTI{i}.pauseRefresh(end));'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {			
			'if (MTI{i}.postBGframes>=0),'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
			'if (MTI{i}.ds.makeClip), Screen(StimWindow,''SetDrawingRegion'',StimWindowRect); end;'
		'elseif strcmp(MTI{i}.ds.displayType,''Sound''),'
			'Snd(''Open'');'
			'if MTI{i}.preBGframes>=0,'
				'Screen(StimWindow,''FillRect'',0);'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'			
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
			'if (MTI{i}.postBGframes>=0),'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
			'Snd(''Close'');'
		'elseif strcmp(MTI{i}.ds.displayType,''custom''),'
			'if MTI{i}.preBGframes>=0,'
				'Screen(StimWindow,''FillRect'',0);'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(1) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.preBGframes);'
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
					'MTI{i}.frameTimes(stampNum)=GetSecs; stampNum=stampNum+1;WaitSecs(1/10000);'
					'end;'});
					if NSUsePCIDIO96Trigger,innerloop=cat(1,innerloop,PCIDIO96beforeframe);end;
	innerloop = cat(1,innerloop, {					
			'end;'});
			if NSUsePCIDIO96Trigger, innerloop=cat(1,innerloop,PCIDIO96afterstim); end;
	innerloop = cat(1,innerloop, {
			'if (MTI{i}.postBGframes>=0),'
				'Screen(StimWindow,''SetClut'',MTI{i}.ds.clut_bg);'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'Screen(StimWindow,''WaitBlanking'',MTI{i}.postBGframes);'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'else,'
				'MTI{i}.startStopTimes(3) = GetSecs;'
				'MTI{i}.startStopTimes(4) = GetSecs;'
			'end;'
		'end;'});
	innerloop = cat(1,innerloop,{'fprintf('' waiting for low gobit>''); VDAQ_Response=1;'
							'while VDAQ_Response==1,'
								'[VdaqUserBByteIn,error]=DIG_In_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqUserOutBPort);'
								'VDAQ_Response = bitget(VdaqUserBByteIn,7);'  % 7 is go bit
							'end;'
							'fprintf(''Go bit low>'');WaitSecs(0.01);' %WaitSecs is for debouncing
							'[VdaqStimByteIn, error] = DIG_In_Port(NSPCIDIO96.deviceNumber,NSPCIDIO96.VdaqStimOutPort);'
			'stimid = bitget(VdaqStimByteIn,7)*1+bitget(VdaqStimByteIn,6)*2+bitget(VdaqStimByteIn,5)*4+bitget(VdaqStimByteIn,4)*8+bitget(VdaqStimByteIn,3)*16;'
			'fprintf(''ending stimid is %4d, elapsed time %.5f\n'',stimid,toc);'
		'if ISstimgo, ISstimnum=ISstimnum+1;end;'
		'if ~isempty(ISstim)&ISstimgo==0, ISstimgo = 1; elseif ~isempty(ISstim)&ISstimgo==1, ISstimgo=0; end;'
		'i=i+1;'}); % end loop over stims

    Screen('Screens'); try, Snd('Open'); Snd('Close'); end;
	if ~abortable,
		loop = cat(1,loop,innerloop);
    	RUSH(loop,prioritylevel);
	else,
		going = 1;
		try, RUSH(loop,prioritylevel);
		catch, going = 0;
		end;
		mykey=KbCheck;
		while ~mykey&going,
			RUSH(innerloop,prioritylevel);
			mykey=KbCheck;
		end;
		if ~going, disp(['DisplayStimScriptIntrinsic exited on error: ' lasterr '.']); end;
		if mykey, clear mex; end;
	end;

	if 0,
		bigchar = [];   % for debugging
		for i=1:length(loop),
			bigchar = [ bigchar loop{i}];
		end;
		eval(bigchar);
	end;
	ShowCursor;
