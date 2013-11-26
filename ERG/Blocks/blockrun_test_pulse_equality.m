%function result = erg_block_run_test_pulse_equality(block)
  global calib blockRunData;

  d = block.data4type.test_pulse_equality;

  nReps = str2num(d.numrepeats);
  nAvgs = str2num(d.numavgs);
  blockRunData.nSweeps = nReps * nAvgs * 3;
  [cond volt time fill levels] = erg_io_convertCalibEQ(d.led);
  
  cond = repmat([repmat(cond(1),[1,nAvgs]) repmat(cond(2),[1,nAvgs]) repmat(cond(3),[1,nAvgs])],[1,nReps]);
  volt = repmat([repmat(volt(1),[1,nAvgs]) repmat(volt(2),[1,nAvgs]) repmat(volt(3),[1,nAvgs])],[1,nReps]);
  time = repmat([repmat(time(1),[1,nAvgs]) repmat(time(2),[1,nAvgs]) repmat(time(3),[1,nAvgs])],[1,nReps]);
  fill = repmat([repmat(fill(1),[1,nAvgs]) repmat(fill(2),[1,nAvgs]) repmat(fill(3),[1,nAvgs])],[1,nReps]);
  light_off = erg_io_convertCalib('justoff');
  
  blockRunData.start = now();
  for i = 1:blockRunData.nSweeps
    [blockRunData.msecs, multiChannelResponse] = erg_io_sendpulse_simple(erg_io_switchCondition(cond{i}), str2num(d.prepulse), light_off, time(i), volt(i), str2num(d.postpulse)+fill(i), light_off);
    for j = 1:block.numchannels
      eval(['blockRunData.data' num2str(j) '(i,:) = multiChannelResponse(j,:);']); 
    end

      blockRunData.nSamples = length(blockRunData.data1(i,:));
      blockRunData.nProgress = i;
      pause(str2num(d.pausetime)/1000);
      if (~blockRunData.isRunning) 
          result = -1;
          return;
      end
      erg_block_run_pulsefeedback();
  end
  blockRunData.end = now();
  blockRunData.isRunning = 0;
  result = 1;
