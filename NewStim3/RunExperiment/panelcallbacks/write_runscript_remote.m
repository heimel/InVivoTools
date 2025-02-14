function write_runscript_remote(pathname, scriptName, saveWaves, outfile,extradevcode)

% WRITE_RUNSCRIPT_REMOTE Send commands to run a stimscript remotely
%
%  WRITE_RUNSCRIPT_REMOTE(PATHNAME,SCRIPTNAME,SAVEWAVES,OUTFILE,...
%       EXTRA_DEVICE_CODE)
%
%  This function is part of the NelsonLabTools package.  It writes
%  instructions for showing a stimulus script after the user clicks
%  'Show Script' in the RunExperiment window.
%
%  PATHNAME is the remote directory location to save stimulus
%    timing information (frame times, etc.)
%  SCRIPTNAME is the name of the script to run
%  SAVEWAVES is 0/1; are we saving the stimulus timing info (1) or
%     just displaying without saving (0)
%  OUTFILE is the local filename where the instructions are written
%  EXTRA_DEVICE_CODE Optional string or cell list of strings that
%     can issue commands to other devices.

if nargin>4
	edc = extradevcode;
else
	edc = []; 
end

NewStimGlobals;

pathname = localpath2remote(pathname);

fid = fopen(outfile,'wt');

if fid==-1
    errormsg(['Could not open ' outfile ' for writing.']);
    return
end

 % if we're running the ReceptiveFieldMapper or if the stimscript isn't
 % actually there or not loaded, then don't show and beep an error message below
fprintf(fid,'ReceptiveFieldGlobals; if (isempty(RFparams)||RFparams.state==0)&&(exist(''%s'')==1&&isloaded(%s)),',scriptName,scriptName);

% make sure screen is up, compute stimulus timings
fprintf(fid,'ShowStimScreen\n');
fprintf(fid,'MTI = DisplayTiming(%s);\n',scriptName);

% still needed for moving acqparams file
if saveWaves,  % calculate the stimulus time for the acquisition computer so it knows how long to record
    fprintf(fid, ...
        'adjust_duration(''acqParams_in'',%s,[''%s'' filesep ''acqParams_in'']);\n', ...
        scriptName,pathname);
end;

if ~isempty(edc),  % print any extra device code here
	if ischar(edc)
		fprintf(fid,edc);
	elseif iscell(edc) % is a cell list
		for i=1:length(edc), fprintf(fid,edc{i}); end;
	end;
end;

if saveWaves,
	fprintf(fid,['pause(' num2str(NewStimStimDelay) ')\n']);  % necessary in practice to give acquisition computer time to get ready
end

% actually show the script
% IT IS UNLIKELY ONE WOULD WANT TO MODIFY HERE TO THE END

fprintf(fid,'[MTI2,start]=DisplayStimScript(%s,MTI,0);\n',scriptName);

if saveWaves, % save the stimulus timings;
  fprintf(fid,'gggg = pwd; cd(''%s'');\n',pathname);
  fprintf(fid,'eval([''saveScript = strip(%s)'']);\n',scriptName);
  fprintf(fid,'MTI2 = stripMTI(MTI2);\n');
  fprintf(fid,'StimWindowGlobals;\n');
  fprintf(fid,'zzz=clock;');
  % writing stims.mat
  
  % write NewStimPixelsPerCm = pixels_per_cm
  fprintf(fid,'NewStimGlobals;if ~exist(''NewStimPixelsPerCm'');NewStimPixelsPerCm=pixels_per_cm;end;');
  
  fprintf(fid,'save(''stims.mat'',''-v7'',''MTI2'',''start'',''saveScript'',''StimWindowRefresh'',''NewStimViewingDistance'',''NewStimPixelsPerCm'');\n');
  fprintf(fid,'disp(''saved stimulus'');cd(gggg);\n');
  % generally acqusition continues a few seconds longer than the stimulus presentation
  % to make sure all is acquired, so we pause here so the user cannot
  % start another stimulus before acquisition is done.
end;

 % beep error messages if not loaded, doesn't exist, or if RFMapper was running
fprintf(fid,'else, StimErrorSound;');
fprintf(fid,'end;');  % ends the if loop with ReceptiveFieldMapper
fclose(fid);
