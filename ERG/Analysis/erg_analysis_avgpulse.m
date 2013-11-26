% This function averages a dataset(sweeps, samplesPerSweep). 
% Outlier sweeps are removed. 

function [data_out, nRemoved] = erg_analysis_avgpulse(data_in, graphs)
  if (nargin < 2) graphs = 0; end
  [nSweeps,nSamples] = size(data_in);
  if (nSweeps <=1) data_out = data_in; nRemoved = [0]; return; end;

  data_out = mean(data_in);
  
  for (i = 1:nSweeps)
    StripMean =  data_out-data_in(i,:);
    if (graphs) sweepDivRun(i,:) = StripMean; end;
    sweepDivRMS(i) = sqrt(sum(StripMean.*StripMean));
  end
  
  m = median(sweepDivRMS);
  sd = m+3*(m-min(sweepDivRMS));

  nRemoved = sum(sweepDivRMS>sd);
  if (nRemoved>0) 
      data_out = ((sweepDivRMS<=sd)*data_in)./(nSweeps-nRemoved);
  end

  if (graphs) 
    global f1 f2 f3;
    figure(f1); hold off; plot(sweepDivRun'); 
    figure(f2); hold off; plot(sweepDivRMS,'g.'); hold on;
    w=m     ; plot([1 i], [w,w], 'r:');   
    w=sd    ; plot([1 i], [w,w]);   
    figure(f3); 
    hold off; 
    plot(mean(data_in),'r'); hold on; 
    plot(data_out,'g');
  end

