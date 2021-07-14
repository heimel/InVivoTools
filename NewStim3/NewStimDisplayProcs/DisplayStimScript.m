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
%
%  200X, Steve Van Hooser
%  200X-20017, Alexander Heimel 

NewStimGlobals;
StimWindowGlobals;
StimTriggerOpen;

if nargin<5 || isempty(capture_movie)
    capture_movie = false; 
end

if nargin<2 || isempty(MTI)
    MTI = DisplayTiming(stimScript); 
end

prioritylevel = MaxPriority(StimWindowMonitor,'WaitBlanking','SetClut','GetSecs'); % PD

if nargin>=3
    if ~isempty(priorit)
        prioritylevel = priorit;
    else % set priority level more carefully if sound is going to be played
        for i=1:length(MTI)
            if strcmp(MTI{i}.ds.displayType,'Sound')
                prioritylevel=0; 
            end
        end
    end
end

abortable = 1;

if nargin>=4
    abortable = abtable; 
end

numstims = numStims(stimScript);

if ~isloaded(stimScript)
    errormsg('Cannot display unloaded stimuli'); 
    return
end

% now get ready to display

StimTriggerAct('Trigger_Initialize');

HideCursor;
ShowStimScreen;  % make sure screen is up

if capture_movie && usejava('jvm') && ispc
    disp('Recording a movie while JAVA capabilities is turned on is not supported by');
    disp('Psychtoolbox and gstreamer. Start matlab without java by typing matlab -nojvm');
    disp('in a command window. Then load your script (e.g. ps) and at the matlab prompt');
    disp('type NSCaptureMovie(ps) to write a movie to your current folder.');
    capture_movie = false;
end

if capture_movie
    disp('DISPLAYSTIMULUS: Creating movie. This will be slow!');
    moviefilename = 'stimulus_movie.mov' ;
    try
        moviePtr = Screen('CreateMovie', StimWindow, moviefilename,[],[],StimWindowRefresh);
        disp(['DISPLAYSTIMULUS: Writing stimulus movie in ' fullfile(pwd,moviefilename)]);
    catch
        disp('DISPLAYSTIMULUS: If codec missing on linux, run: sudo apt-get install ubuntu-restricted-extras gstreamer-tools');
        disp('DISPLAYSTIMULUS: Use gst-inspect to check which codecs are installed');
    end
end
Screen('screens'); 

Screen(StimWindow,'WaitBlanking');
startTrig = StimTriggerAct('Script_Start_trigger');

if NSUseInitialSerialTrigger
    OpenStimSerial
    StimSerial(StimSerialScriptOutPin,StimSerialScript,0);

    if exist('NSUseInitialSerialContinuous','var') && ~isempty(NSUseInitialSerialContinuous) && NSUseInitialSerialContinuous
        StimSerial(StimSerialScriptOutPin,StimSerialScript,0);
        disp(['DISPLAYSTIMSCRIPT: ' StimSerialScriptOutPin ' pin flipped down for whole script']);
    else
        WaitSecs(0.001);
        StimSerial(StimSerialScriptOutPin,StimSerialScript,1);
        disp(['DISPLAYSTIMSCRIPT: ' StimSerialScriptOutPin ' pin flipped down for 1 ms']);
    end
end

l = length(MTI);
trigger = getTrigger(stimScript); %#ok<NASGU>

if ~abortable
    Rush('for i=1:l, [MTI{i}.startStopTimes,ft] = DisplayStimulus(MTI{i},get(stimScript,MTI{i}.stimid),trigger(i),capture_movie); MTI{i}.frameTimes = ft; end; Screen(StimWindow,''FillRect'',0);', prioritylevel);
else
    if StimDisplayOrderRemote
        abort = 0;
        lpt = open_parallelport;
        ready = 0;
        while ~abort
            %	[thetime,i] = StimTriggerAct('WaitActionCode');
            [go,i] = get_gostim(lpt); %#ok<ASGLU>
            if ~go    % go has to be off, before another stimulus is shown
                ready=1;
            end
            if go && ready
                Rush('DisplayStimulus(MTI{i},get(stimScript,MTI{i}.stimid),trigger(i),capture_movie);',prioritylevel);
                ready=0;
            end
            abort = KbCheck;
        end
    else
        for i=1:l
            disp(['current stimID:      ',num2str(i),''])
            Rush('[MTI{i}.startStopTimes,ft]=DisplayStimulus(MTI{i},get(stimScript,MTI{i}.stimid),trigger(i),capture_movie);MTI{i}.frameTimes=ft;',prioritylevel);
            if KbCheck % abort if keyboard press
                break
            end
            if mod(i,20)==0
                fprintf(['Just finished stim ' int2str(i) ' of ' int2str(l) '.\n']);
            end
            if mod(i,numstims)==0
                fprintf(['Just finished trial ' int2str(i/numstims) ' of ' int2str(l/numstims) '.\n']);
            end
        end
    end
end

if NSUseInitialSerialTrigger
    StimSerial(StimSerialScriptOutPin,StimSerialScript,1);
end

if capture_movie
    Screen('FinalizeMovie',moviePtr);
    logmsg(['Wrote movie ' moviefilename]);
end

ShowCursor;
