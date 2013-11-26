function erg_protocol_run(protocol)
  global protocolRunData;
  
  if (isempty(protocolRunData))  % || ~protocolRunData.isRunning
      protocolRunData.isRunning = 0;
  end
  
  if (strcmp(protocol,'stopandreset'))
      protocolRunData.isRunning = 0;
      return;
  end
  if (protocolRunData.isRunning > 0)
    disp('A protocol run is already in progress');  
    return;
  end
  
  protocolRunData.isRunning = 1;
  
  ergLogger('add',{'protocolrunstart',now(),now(),'Protocol run started','','',[],[]});
  for (i = 1:protocol.numItems)
    erg_block_run(protocol.items(i));
    if(protocolRunData.isRunning == 0) 
       ergLogger('add',{'protocolrunend',now(),now(),'Protocol run ABORTED','','',[],[]});
       return;
    end 
  end

  ergLogger('add',{'protocolrunend',now(),now(),'Protocol run finished','','',[],[]});
  protocolRunData.isRunning = 0;
      
      