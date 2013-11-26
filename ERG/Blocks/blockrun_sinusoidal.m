%function result = erg_block_run_sinusoidal(block)
  global calib blockRunData ao;
  d = block.data4type.sinusoidal;
 
  nSteps = str2num(d.frq_steps);
  fStart = str2num(d.frq_start);
  fEnd = str2num(d.frq_end);
  nMsecs = str2num(d.duration);
  nSamps = round(nMsecs * ao.SampleRate/1000);
  % channel = erg_io_switchCondition();
  % blockRunData.levels(1:3,nSteps) = 1;
  
  blockRunData.nSweeps = nSteps;
  blockRunData.nSamples = nSamps;
  frqs = linspace(fStart, fEnd, nSteps);
  blockRunData.levels = frqs;
  blockRunData.msecs = nMsecs;

  blockRunData.start = now();
  for i = 1:nSteps
    period = round(1./frqs(i) * ao.SampleRate);
    onePeriod = sin(linspace(0,2*pi,period))*4;
    maxSignal = repmat(onePeriod,[1,ceil(nSamps/period)]);
    finalSignal = maxSignal(1:nSamps);
  
    multiChannelResponse = erg_io_senddata(d.LED, finalSignal);
    for j = 1:block.numchannels
      eval(['blockRunData.data' num2str(j) '(i,:) = multiChannelResponse(j,:);']); 
    end
    
    pause(str2num(d.pause)/1000);
    blockRunData.nProgress = i;
    if (~blockRunData.isRunning) 
      result = -1;
      return;
    end
    erg_block_run_pulsefeedback();
  end
  blockRunData.end = now();
  blockRunData.isRunning = 0;
  result = 1;
