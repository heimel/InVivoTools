% This function is not so complex. Actually it only gives interesting
% results when start- and endfrequency are the same. Then it gives the
% average. 
%
% A next step could be dissecting each single 'sweep' in the same
% periods as the stimulus was presented, and average that. That could be
% done for each frequency step and parameters could be deduced and plotted
% in frequency vs paramater-value plots.

function erg_analysis_block_sinusoidal(filename, calibfilename)
  global ergConfig;

  [block duration stimuli] = erg_getdata_div(filename);
  accepted_types = {'sinusoidal'};
  if (~ismember(block.type,accepted_types)) disp('Can not analyze this blocktype with this type of analysis, I am so sorry!'); return; end;
  load(calibfilename, 'calib_saved'); 
  data_saved = erg_getdata_raw(filename);

  d = data_saved.block.data4type.sinusoidal;

  for chan = 1:block.numchannels
    resultset = data_saved.(['results' num2str(chan)]);
%    figure;
%    subplot(2,3,3); hold off; plot(resultset'); 

    nMsecs = data_saved.msecs;
    nSamps = size(resultset,2);
    nSrate = nSamps/(nMsecs/1000);

    for i=1:size(resultset,1)
      nSampsPerPeriod = (1/data_saved.stimuli(i))*nSrate;
      nPeriods2Analyse = floor((nSamps/2)/nSampsPerPeriod)
%     if (nPeriods2Analyse>0)
%       subplot(2,size(resultset,1),size(resultset,1)+i); plot(1:round(nSampsPerPeriod),resultset(i,1:round(nSampsPerPeriod)));
%     end
    end

   [A, B] = erg_analysis_avgpulse(resultset(:,:),0); %overall average, only informative when frequency remains constant
   figure; plot(1000*A/nSrate);
   title(['Channel ' num2str(chan)]);
   set(gcf,'name',['Channel ' num2str(chan)]);
 end;