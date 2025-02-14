function responses=calculate_responses(cksds,testname,cellname,bins,repeats)
%CALCULATE_RESPONSES calculates responses to movie stimuli from recorded test
%  
%  RESPONSES=CALCULATE_RESPONSES(CKSDS,TESTNAME,CELLNAME,BINS,REPEATS)
%
%  PERHAPS A BUG IF NO SPIKES AT ALL ARE REGISTERED DURING TRIAL
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
  finished_extracting=0;
  while ~finished_extracting
    %fprintf('.');
    
    if 0
      pause(1);
    else
      inp=input(['Hit return when finished extracting. (c to' ...
		 ' continue)'],'s');
      if strcmp(inp,'c')
	responses=[]; % do something else
	finished_extracting=1;
	break;
      end
    end

    try
      s = getstimscripttimestruct(cksds,testname);
      data=load(getexperimentfile(cksds),cellname,'-mat');
      spikedata=getfield(data,cellname); % TEMPORARY

      % get triggers
      sms=get(s.stimscript,1);
      f=getshapeframes(sms);
      triggers=s.mti{1}.frameTimes(f);
      
      % get responses of first repeat
      [responses(:,:,1),psth]=fastraster(spikedata,triggers,bins);

      % get rest of responses
      for i=2:repeats
	triggers=s.mti{i}.frameTimes(f);
	[responses(:,:,i),psth]=fastraster(spikedata,triggers,bins);
      end     

      finished_extracting=1;
  catch
    %disp('Not yet finished with the extraction.');
      lasterr
      finished_extracting=0;
    end
  end
%  fprintf('\n');
