function result = erg_block_run_initRunData()
  global blockRunData ergConfig;
  if (isempty(blockRunData) || ~blockRunData.isRunning)
      blockRunData.isRunning = 0;

      for i = 1:ergConfig.maxInputChannels
        eval(['blockRunData.data' num2str(i) '=[];']);
      end
        
      blockRunData.data = [];
      blockRunData.levels = [];
      blockRunData.nSweeps = 0;
      blockRunData.nProgress = 0;
      blockRunData.msecs = 0;
      blockRunData.nSamples = 0;
      blockRunData.nChannels = 0;
  end
  
  if (blockRunData.isRunning) 
      disp('there''s already another block running!');
      result = -1;
      return;
  end
  blockRunData.isRunning = 1;
  result = 0;
