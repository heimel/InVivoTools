function erg_analysis_block_equality(filename, calibfilename)
  global ergConfig;

  load(calibfilename, 'calib_saved'); 
  data_saved = erg_getdata_raw(filename);
  accepted_types = {'test_pulse_equality'};
  if (~ismember(data_saved.block.type,accepted_types)) disp('Can not analyze this blocktype with this type of analysis, I am so sorry!'); return; end;
  load(calibfilename, 'calib_saved'); 

  try
    figure(ergConfig.subplotfig);
    subplot1(16);
  catch  
    ergConfig.subplotfig =  figure(1); subplot1(4,4,'Gap',[0.02 0.02]); hold off; 
  end

  d = data_saved.block.data4type.test_pulse_equality;
  
  nReps = str2num(d.numrepeats);
  nAvgs = str2num(d.numavgs);
  totsamples = size(data_saved.results1,2);

  %Backwards compatibility: the earlier acquired equality tests did only
  %1/3rd of the pulses, counter-intuitively and all. But now we use this to
  %discern older versions: 3(conditions)*avgs*repeats != total amount of
  %sweeps. Back than all parties assumed the settings were 30
  %avg and 10 repeats, which eases analysis. This would boil down to:  
  %30x1,30x2,30x3,30x1,30x2,30x3,30x1,30x2,30x3,30x1 
  if (3 * nReps * nAvgs ~= size(data_saved.results1,1))
    data_saved.stimuli = Expand([1;2;3;1;2;3;1;2;3;99],1,30)';
  else %nowadays we are a little more flexible and all since we fixed blockrun_test_pulse_equality
    data_saved.stimuli = Expand(repmat([1;2;3],[nReps,1]),1,nAvgs)';
  end
  
  for chan = (1:data_saved.block.numchannels)
    Srt = sortrows([data_saved.stimuli; data_saved.(['results' num2str(chan)])']')'; 
    dataset = -1.*Srt(2:size(Srt,1),:)';
 
    graphs_avg = 0;
    sweeps_size  = str2num(d.numavgs)*3;
    prepulse_samples = min([totsamples, str2num(d.prepulse)*(totsamples/data_saved.msecs)]);
    resultset = ones(3,size(dataset(1,:),2));
    
    for (i = 1:3)
      [resultset(i,:), nRemoved(i)] = erg_analysis_avgpulse(dataset((i-1)*sweeps_size+1:i*sweeps_size,:),graphs_avg);
      [baseline(i) awave(i) atime(i) bwave(i) btime(i)] = erg_analysis_getab(resultset(i,:),prepulse_samples,data_saved.msecs);
    end 

    figure(ergConfig.subplotfig); hold off; 
    subplot1((chan-1)*8+1); hold off; plot(1:3,awave-baseline,'b',1:3,bwave-awave,'r');
    subplot1((chan-1)*8+2); hold off; plot(1:3,atime/10,'b',1:3,btime/10+30,'r');
    subplot1((chan-1)*8+3); hold off; 
    cA = calib_saved.(['greenLow']);  cB = calib_saved.(['greenHigh']);   cC = calib_saved.(['blueLow']);   cD = calib_saved.(['blueHigh']);   cE = calib_saved.(['UVLow']);    cF = calib_saved.(['UVHigh']);
    plot(cA.in,cA.out,'g:',cB.in, cB.out/100,'g-'); hold on;
    plot(cC.in,cC.out,'b:',cD.in, cD.out/100,'b-'); hold on;
    plot(cE.in,cE.out,'m:',cF.in, cF.out/100,'m-');
    subplot1((chan-1)*8+4); hold off;  plot(1:3,nRemoved,'r.');   

    figure; clf;
    set(gcf, 'name',['Channel ' num2str(chan) ' equality test results']);

    dstart = 1;
    dend = min(totsamples,prepulse_samples+2000);
    X = repmat((dstart-round(prepulse_samples):dend-round(prepulse_samples))/(totsamples/data_saved.msecs),[3,1])';
    Y = resultset(:,dstart:dend)';
    plot(X,Y);   
    %scatter(X(1,:),Y(1,:));
    xlim([X(1),X(end)]);
    hold on; plot(0,ylim);
    hold on; plot(repmat(xlim,[3,1])',[bwave;bwave]);
    title(['Channel ' num2str(chan) ' equality test results']);
  end
