global calib blockRunData;

d = block.data4type.pulsetrain;

nReps = str2num(d.numrepeats);
nStep = str2num(d.pulse_steps);
blockRunData.nSweeps = nStep * nReps;

if (d.steps_lin)
  blockRunData.levels(1,:) = linspace(str2num(d.pulse_green_start),str2num(d.pulse_green_end),nStep);
  blockRunData.levels(2,:) = linspace(str2num(d.pulse_blue_start),str2num(d.pulse_blue_end),nStep);
  blockRunData.levels(3,:) = linspace(str2num(d.pulse_UV_start),str2num(d.pulse_UV_end),nStep);
else
  blockRunData.levels(1,:) = logspace(mylog(str2num(d.pulse_green_start)),mylog(str2num(d.pulse_green_end)),nStep);
  blockRunData.levels(2,:) = logspace(mylog(str2num(d.pulse_blue_start)),mylog(str2num(d.pulse_blue_end)),nStep);
  blockRunData.levels(3,:) = logspace(mylog(str2num(d.pulse_UV_start)),mylog(str2num(d.pulse_UV_end)),nStep);
end

if (d.repeat_intensities)
  if (d.shuffle_episodes) blockRunData.levels = erg_analysis_shuffle(blockRunData.levels); end
  dummy = blockRunData.levels;
  blockRunData.levels = [];
  for (i = 1:str2num(d.pulse_steps))
    blockRunData.levels(:,1+(i-1)*nReps:i*nReps) = repmat(dummy(:,i),[1,nReps]);
  end
  if (d.shuffle_all) blockRunData.levels = erg_analysis_shuffle(blockRunData.levels); end
else
  blockRunData.levels = repmat(blockRunData.levels,[1,str2num(d.numrepeats)]);
  if (d.shuffle_episodes); for i = 1:nReps; blockRunData.levels(:,1+(i-1)*nStep:i*nStep) = erg_analysis_shuffle(blockRunData.levels(:,1+(i-1)*nStep:i*nStep)); end; end;
  if (d.shuffle_all); blockRunData.levels = erg_analysis_shuffle(blockRunData.levels); end;
end

bg_LEDS = [str2num(d.bg_green),str2num(d.bg_blue),str2num(d.bg_UV)];

blockRunData.start = now();
for i = 1: blockRunData.nSweeps
  [blockRunData.msecs, multiChannelResponse] = erg_io_sendpulse_complex( blockRunData.levels(:,i),str2num(d.prepulse),str2num(d.postpulse),bg_LEDS);
  
  for j = 1:block.numchannels
    eval(['blockRunData.data' num2str(j) '(i,:) = multiChannelResponse(j,:);']); 
  end
  
  blockRunData.nSamples = size(multiChannelResponse,2);
  blockRunData.nProgress = i;
  pause(str2num(d.pausetime)/1000);
  if (~blockRunData.isRunning)
    result = -1;
    return;
  end
  erg_block_run_pulsefeedback();
end

if (d.bg_after_off) erg_io_lampoff('all'); end;

blockRunData.end = now();
blockRunData.isRunning = 0;
result = 1;
