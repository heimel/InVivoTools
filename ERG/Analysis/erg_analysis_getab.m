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

  totsamples = length(data);
  prepulse_samples = min([totsamples, prepulse_samples]);

  awave_find_start = prepulse_samples;
  awave_find_end   = min([totsamples, prepulse_samples+30*(totsamples/duration)]);
  bwave_find_start = min([totsamples, prepulse_samples+15*(totsamples/duration)]) ;
  bwave_find_end   = min([totsamples, prepulse_samples+100*(totsamples/duration)]) ;

  % filter bwave to remove effect of oscillatory potentials
  bwavedata = erg_analysis_smoothen( data, duration/size(data,2));
  
  baseline = mean(data( max([1,prepulse_samples-ergConfig.max_prepulse_samples]):prepulse_samples));
%  baseline = mean(data(1:prepulse_samples));
  [awave,atime] = min(data(awave_find_start:awave_find_end));
  [bwave,btime] = max(bwavedata(bwave_find_start:bwave_find_end));

  %The next two lines do the noise-filtering part to correct for min/max bias
  bwave = bwave - min(prctile(data(1:prepulse_samples/2)-mean(data(1:prepulse_samples/2)),95),prctile(data(prepulse_samples/2+1:prepulse_samples)-mean(data(prepulse_samples/2+1:prepulse_samples)),95));
  awave = awave - max(prctile(data(1:prepulse_samples/2)-mean(data(1:prepulse_samples/2)),5),prctile(data(prepulse_samples/2+1:prepulse_samples)-mean(data(prepulse_samples/2+1:prepulse_samples)),5));
