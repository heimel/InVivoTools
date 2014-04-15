function [baseline awave atime bwave btime] = erg_analysis_getab(data, prepulse_samples, duration)
%ERG_ANALYSIS_GETAB Calculates baseline and amplitude&time of awave/bwave 
%  usage: [baseline awave atime bwave btime] = erg_analysis_getab(data, prepulse_samples, duration): 
%  - data = 1 dimensional matrix with response data (useally the sample average)
%  - prepulse_samples = amount of SAMPLES before pulse
%  - duration = # of msecs the data covers (samplerate is derived from duration and length of data)
%
%  Note: now we have defined a/b wave detection in a seperate function, we
%  can easily adjust the parameters and such. 
  global ergConfig
  
  
  data = data/ergConfig.voltage_amplification*1000000; % uV

  totsamples = length(data);
  prepulse_samples = min([totsamples, prepulse_samples]);
  
  sample_time = duration/(totsamples-1);
  time = ((1:totsamples)-prepulse_samples)*sample_time;
  
  awave_find_start = prepulse_samples;
  awave_find_end   = min([totsamples, prepulse_samples+30*(totsamples/duration)]);
  bwave_find_start = min([totsamples, prepulse_samples+15*(totsamples/duration)]) ;
  bwave_find_end   = min([totsamples, prepulse_samples+100*(totsamples/duration)]) ;

  
  
  
  baseline = mean(data( max([1,prepulse_samples-ergConfig.max_prepulse_samples]):prepulse_samples));
  data = data - baseline;

  
  if 1  % filter bwave to remove effect of oscillatory potentials
      bwavedata = erg_analysis_smoothen( data, duration/size(data,2));
  else
      bwavedata = data;
  end
  
  %  baseline = mean(data(1:prepulse_samples));
  [awave,atime] = min(data(awave_find_start:awave_find_end));
  [bwave,btime] = max(bwavedata(bwave_find_start:bwave_find_end));

  %The next two lines do the noise-filtering part to correct for min/max bias
  if 0
      bwave = bwave - min(prctile(data(1:prepulse_samples/2)-mean(data(1:prepulse_samples/2)),95),prctile(data(prepulse_samples/2+1:prepulse_samples)-mean(data(prepulse_samples/2+1:prepulse_samples)),95));
  end
  if 0
      awave = awave - max(prctile(data(1:prepulse_samples/2)-mean(data(1:prepulse_samples/2)),5),prctile(data(prepulse_samples/2+1:prepulse_samples)-mean(data(prepulse_samples/2+1:prepulse_samples)),5));
  end
  
  awave = -awave;
  bwave = bwave + awave;
  if bwave<awave
      bwave = awave;
  end
  
 % figure;
  hold on
  plot([time(1) time(end)],[0 0],'--','color',[0.7 0.7 0.7]);
  plot(time,data,'k');
  plot(time,bwavedata,'k--');
  xlim([-40 160])
  axis square
  ax = axis;
  plot([0 0],[ax(3) ax(4)],'-y');
  width5 = 0.03*(ax(2)-ax(1));
  plot( (awave_find_start+atime-prepulse_samples)*sample_time+[-width5 width5],[-awave -awave],'r-');
  plot( (awave_find_start+[atime atime]-prepulse_samples)*sample_time,[0 -awave],'r-');
  plot( (bwave_find_start+btime-prepulse_samples)*sample_time+[-width5 width5],[bwave-awave bwave-awave],'r-');
  plot( (bwave_find_start+btime-prepulse_samples)*sample_time+[-width5 width5],[-awave -awave],'r-');
  plot( (bwave_find_start+[btime btime]-prepulse_samples)*sample_time,[-awave bwave-awave],'r-');
  ylabel('Amplitude (muV)')
  xlabel('Time (ms)');
  
  