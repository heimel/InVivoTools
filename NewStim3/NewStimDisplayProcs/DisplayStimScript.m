function [MTI,startTrig] = DisplayStimScript(stimScript, MTI, priorit,abtable,capture_movie)
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
%  If CAPTURE_MOVIE, a movie will be created of the stimulus. This can
%  delay presenting the stimulus, and should NOT be run in a experiment
%  setting.
%
%  Bugs:  The system will hang if one tries to show a stimulus with clipping on the first
%  run after booting at max priority.  As a work-around, either first run a script without
%  any clipping or run the stimulus through one time at priority 0.
%  I do not know why this happens.
%
%  Sound sometimes has errors if it is not run at priority 0.


NewStimGlobals;
StimWindowGlobals;
StimTriggerOpen;

if nargin<5; capture_movie = []; end;
if isempty(capture_movie); capture_movie = false; end

if nargin<2, MTI = DisplayTiming(stimScript); end;
	
if isempty(MTI), MTI = DisplayTiming(stimScript); end;

prioritylevel = MaxPriority(StimWindowMonitor,'WaitBlanking','SetClut','GetSecs'); % PD

if nargin>=3,
	if ~isempty(priorit),
		prioritylevel = priorit;
	else, % set priority level more carefully if sound is going to be played
		for i=1:length(MTI),
			if strcmp(MTI{i}.ds.displayType,'Sound'),prioritylevel=0; end;
		end;
	end;
end;

abortable = 1;

if nargin>=4, abortable = abtable; end;

numstims = numStims(stimScript);

if ~isloaded(stimScript), error(['Cannot display unloaded stimuli']); end;

 % now get ready to display

StimTriggerAct('Trigger_Initialize');

HideCursor;
ShowStimScreen;  % make sure screen is up

if capture_movie
    disp('DISPLAYSTIMULUS: Creating movie. This will be slow!');
    moviefilename = fullfile(getdesktopfolder,'stimulus_movie.mov');
    try
        moviePtr = Screen('CreateMovie', StimWindow, moviefilename,[],[],StimWindowRefresh);
    catch
        disp('DISPLAYSTIMULUS: If codec missing on linux, run: sudo apt-get install ubuntu-restricted-extras gstreamer-tools');
        disp('DISPLAYSTIMULUS: Use gst-inspect to check which codecs are installed');
    end
end


Screen('screens'); try, Snd('open'); Snd('close'); end;  % warm up these functions, try to get them in memory

Screen(StimWindow,'WaitBlanking');
startTrig = StimTriggerAct('Script_Start_trigger');
Screen(StimWindow,'WaitBlanking');

if NSUseInitialSerialTrigger
   disp('DISPLAYSTIMSCRIPT: Temporarily hard coded StimSerial trigger for LeveltLab');
   OpenStimSerial
 %  stimserial(StimSerialScriptOutPin,StimSerialScript,1);
 %  stimserial(StimSerialStimOutPin,StimSerialStim,1);
   StimSerial(StimSerialScriptOutPin,StimSerialScript,0);
   WaitSecs(0.001);
   StimSerial(StimSerialScriptOutPin,StimSerialScript,1);
  % StimSerial(StimSerialStimOutPin,StimSerialStim,0);
  % StimSerial(StimSerialStimOutPin,StimSerialStim,1);
end
%tic

i = 1;

l = length(MTI);

trigger = getTrigger(stimScript);

if ~abortable,
	Rush('for i=1:l, [MTI{i}.startStopTimes,ft] = DisplayStimulus(MTI{i},get(stimScript,MTI{i}.stimid),trigger(i),capture_movie); MTI{i}.frameTimes = ft; end; Screen(StimWindow,''FillRect'',0);', prioritylevel);
else,
	if StimDisplayOrderRemote,
		abort = 0;
        lpt=open_parallelport;
        ready=0;
		while ~abort,
            %	[thetime,i] = StimTriggerAct('WaitActionCode');
            [go,i]=get_gostim(lpt);
            if ~go    % go has to be off, before another stimulus is shown
                ready=1;
            end
            if go && ready
                if i<1
                    disp('DISPLAYSTIMSCRIPT: Stim 0 requested. Assuming bit 5 is missing and showing stim 16');
                    i = l; % changed on 2013-07-01 (changed by Mehran 2013-08-10)
                end
%                 
%                 if i<1||i>numstims
%                     error(['Requested stimulus ' int2str(i) ' out of range.']); 
%                 end
                Rush('DisplayStimulus(MTI{i},[],trigger(i),capture_movie);',prioritylevel);
                ready=0;
            end
			abort = KbCheck;
		end;
	else,
		for i=1:l,
            disp(['current stimID:      ',num2str(i),''])
            Rush('[MTI{i}.startStopTimes,ft]=DisplayStimulus(MTI{i},get(stimScript,MTI{i}.stimid),trigger(i),capture_movie);MTI{i}.frameTimes=ft;',prioritylevel);
%            disp('DisplayStimScript: TEMPORARILY NOT RUSHING');
 %           eval('[MTI{i}.startStopTimes,ft]=DisplayStimulus(MTI{i},get(stimScript,MTI{i}.stimid),trigger(i));MTI{i}.frameTimes=ft;',prioritylevel);
            if KbCheck, break; end; % abort if keyboard press
            
            % print status
            if mod(i,20)==0,
                fprintf(['Just finished stim ' int2str(i) ' of ' int2str(l) '.\n']);
            end;
            if mod(i,numstims)==0,
                fprintf(['Just finished trial ' int2str(i/numstims) ' of ' int2str(l/numstims) '.\n']);
            end;
            %toc
        end;
        
		%screen(StimWindow,'FillRect',0);
	end;
end;

 % clean up
 if capture_movie
     Screen('FinalizeMovie',moviePtr);
 end

ShowCursor;