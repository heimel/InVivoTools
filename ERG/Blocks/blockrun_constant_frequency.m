global blockRunData ao;

d = block.data4type.constant_frequency;

varFrequency = str2num(d.frequency);
varReps = str2num(d.numrepeats);
varStep = str2num(d.num_intensity_steps);
varStartIntens = str2num(d.startIntensity);
varEndIntens = str2num(d.endIntensity);
varLog = d.logsteps;
varLin = d.linsteps;
varLED = d.LED;
varPause = str2num(d.pausebetween);

blockRunData.nSweeps = varStep;

voltage = -5;

nolight = erg_io_convertCalib('justoff');
if (varLog) intensities = linspace(varStartIntens,varEndIntens,varStep); else
  intensities = logspace(mylog(varStartIntens),mylog(varEndIntens),varStep); end

targets = [1 1 1]*nolight; %g b UV
if (strcmp(varLED,'green')) ledindex = 1; end;
if (strcmp(varLED,'blue'))  ledindex = 2; end;
if (strcmp(varLED,'UV'))    ledindex = 3; end;

blockRunData.data1 = [];
blockRunData.start = now();
for stepNow = 1:round(varStep)
  targets(ledindex) = intensities(stepNow); 

  periodlength = round(1/varFrequency*ao.SampleRate);

  [pulse_condition, pulse_voltage, pulse_time, pulse_fill] = erg_io_convertCalib('pulse', targets)
  uniWave = pulse_voltage(ledindex) * ones(1,round(pulse_time(ledindex)*ao.SampleRate/1000));
  uniWave = [uniWave ones(1,periodlength-length(uniWave))*nolight];
  uniWave = repmat(uniWave,[1 varReps]);
  
  pc_dummy = pulse_condition(ledindex)
  multiChannelResponse = erg_io_senddata(pc_dummy{1}, uniWave);
  for j = 1:block.numchannels
    eval(['blockRunData.data' num2str(j) '(stepNow,:) = multiChannelResponse(j,:);']); 
  end
  
  if (stepNow < round(varStep)) pause(varPause/1000); end
  if (~blockRunData.isRunning) 
    result = -1;
    return;
  end

  blockRunData.nSamples = length(blockRunData.data1(stepNow,:));
  blockRunData.msecs = 1000*(1/varFrequency)*varReps;
  blockRunData.nProgress = stepNow;
  erg_block_run_pulsefeedback();
end

blockRunData.end = now();
blockRunData.isRunning = 0;
result = 1;

