function erg_block_run(block)
  global calib blockRunData ai ao ergConfig;
  if (isempty(calib)) 
      try
        load lastcalib.mat calib
      catch
        disp('ERG_BLOCK_RUN: No calibration present, lastcalib.mat also could not be found.')
      end
  end

  if (strcmp(block,'stopandreset'))
      blockRunData.isRunning = 0;
      try
        stop(ai); stop(ao);
      catch
      end
      return;
  end

  result = -1;
  
  f = fullfile(ergConfig.blockdir,['blockrun_' block.type{1} '.m']);

  if (erg_block_run_initRunData < 0) result = -1; return; end;
  blockRunData.nChannels = block.numchannels;
  
  run(f); 

  if (result <=0) return; end; %Problem encountered, don't save...

  desc = block.data4type.(block.type{1}).description;
  data_tosave.block = block;

  try
    data_tosave.msecs = blockRunData.msecs;
    for i = 1:block.numchannels; data_tosave.(['results' num2str(i)]) = blockRunData.(['data' num2str(i)]); end
    data_tosave.stimuli = blockRunData.levels;
    data_tosave.ergConfigSnapshot = ergConfig; 
  catch
    disp('Error interpreting blockRunData');
  end

  ergLogger('add',{'block',blockRunData.start,blockRunData.end,[block.type{1} ' - ' block.tag],desc,'',data_tosave,calib});

  

  

     
  
