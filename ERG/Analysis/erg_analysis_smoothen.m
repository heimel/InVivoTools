% This function smoothens a dataset. 

function data_out  = erg_analysis_smoothen(data_in, sampletime )
global ergConfig;
  

if isnan(ergConfig.gaussianfilter_bwave)
    data_out = data_in;
    return
end
sigma = ergConfig.gaussianfilter_bwave / sampletime;
 
data_out = smoothen( data_in, sigma);

if 1
   % disp('ERG_ANALYSIS_SMOOTHEN: Showing smooth trace');
    figure;
    plot(data_in,'k');
    hold on
    plot(data_out,'r');
end