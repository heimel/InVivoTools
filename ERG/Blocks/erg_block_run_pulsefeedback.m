function erg_block_run_pulsefeedback()
  global blockRunData;

  for channel = 1:blockRunData.nChannels
    cur = blockRunData.nProgress;
    fig = erg_block_run_ui(channel, 'progress',100/blockRunData.nSweeps*cur);

    handles = guihandles(fig);

    npd = 1;
    curBlockRunData = blockRunData.(['data' num2str(channel)]);
    plotData = [];
    if (get(handles.runui_plotone,'Value')) plotData(:,npd) = curBlockRunData (cur,:)'; npd = npd + 1; end  
    if (get(handles.runui_plotavg,'Value')) plotData(:,npd) = mean(curBlockRunData (1:cur,:)',2); npd = npd + 1; end  
    if (get(handles.runui_plotall,'Value')) plotData(:,npd:npd+cur-1) = curBlockRunData (1:cur,:)'; npd = npd + cur; end  

    if (~isempty(plotData))
      erg_block_run_ui(channel, 'plot',repmat(linspace(0,blockRunData.msecs,blockRunData.nSamples),1,npd-1),plotData); 
    end
  end