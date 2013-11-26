% This function displays some preliminary results in a multiplot figure
% From left to right will be:
% * a-wave troughs (red) and b-wave peaks (blue) of sliding windows
% * a-wave times (red) and b-wave times (blue) of sliding windows
% * a-wave troughs (red) and b-wave peaks (blue) of 1st and 2nd half of the run 
% * a-wave times (red) and b-wave times (blue) of 1st and 2nd half of the run 
%
% Note: slding window widths are half of total amount of sample average
% 
% For multichannel recording it will use the second half of the subplots
% In between erg_analysis_block_pulsetrain will display its results.
%
% The function gathers the data via erg_getdata_raw, so no caching. Fact is
% that it needs the raw data because it calculates averages of so many 
% different subsets.
%

function erg_analysis_block_hysteresis(filename, calibfilename)
  global ergConfig;
  try
    figure(ergConfig.subplotfig);
    subplot1(16);
  catch  
    ergConfig.subplotfig =  figure(1); subplot1(4,4,'Gap',[0.02 0.02]); hold off; 
  end

  data_saved = erg_getdata_raw(filename);
  [block duration stimuli] = erg_getdata_div(filename);
  accepted_types = {'pulsetrain'};
  if (~ismember(block.type,accepted_types)) disp('Can not analyze this blocktype with this type of analysis, I am so sorry!'); return; end;
  load(calibfilename, 'calib_saved'); 
  
  for chan = (1:data_saved.block.numchannels)
    sp1 = 5+(chan-1)*8;
    sp2 = 6+(chan-1)*8;
    sp3 = 7+(chan-1)*8;
    sp4 = 8+(chan-1)*8;

    d = data_saved.block.data4type.pulsetrain;
    Srt = sortrows([data_saved.stimuli; data_saved.(['results' num2str(chan)])']')';
    dataset = -1.*Srt(4:size(Srt,1),:)';
    graphs_avg = 0;

    reps  = str2num(d.numrepeats);
    steps  = str2num(d.pulse_steps);

    totsamples = size(dataset,2);
    prepulse_samples = str2num(d.prepulse)*(totsamples/data_saved.msecs);

    resultset1 = ones(steps,size(dataset(1,:),2));
    resultset2 = ones(steps,size(dataset(1,:),2));
    awave = []; bwave = []; atime=[]; btime=[]; baseline = []; 
    window_size = round(reps/2);
    for (i = 1:steps)
      for (j = 1:reps-window_size)
        [res, rem] = erg_analysis_avgpulse(dataset((i-1)*reps+1+j:(i-1)*reps+window_size+j,:),graphs_avg);
        [baseline(i,j) awave(i,j) atime(i,j) bwave(i,j) btime(i,j)] = erg_analysis_getab(res, prepulse_samples, duration);
      end
    end

    % LinePlots For sliding window and 1st-vs-2nd half test
    [dummy, col] = max(data_saved.stimuli(:,end))
    res2 = []; a = 0; for i = 1:reps:steps*reps; a = a + 1; [n1,n2,n3] = erg_io_convertCalib('pulse',data_saved.stimuli(:,i)); res2(a) = n2(col); end;
    subplot1(sp1); 
    hold off; 
    plot((awave(res2<99,:)-baseline(res2<99,:))',':'); 
    subplot1(sp1); hold on; plot((bwave(res2<99,:)-awave(res2<99,:))','-'); 
    subplot1(sp1); hold on; xl=xlim; yl=ylim; text(xl(1)+1,yl(end)-0.2,'(sliding window, dots=awave)')
    subplot1(sp2); hold off; plot(atime(res2<99,:)'/10,':'); hold on;
    subplot1(sp2); hold on; plot(btime(res2<99,:)'/10+30,'-'); hold off; 
    subplot1(sp2); hold on; xl=xlim; yl=ylim; text(xl(1)+3,yl(end)-10,'(sliding window, dots=atime)')

    X = 1:reps;
    X = X(res2<99)';
    subplot1(sp3); hold off; plot(X,awave(res2<99,1)-baseline(res2<99,1),'b',X,bwave(res2<99,1)-awave(res2<99,1),'r'); 
    subplot1(sp3); hold on; plot(X,awave(res2<99,end)-baseline(res2<99,end),'b:',X,bwave(res2<99, end)-awave(res2<99, end),'r:');
    subplot1(sp3); hold on; xl=xlim; yl=ylim; text(xl(1)+1,yl(end)-0.2,'(red=b, blue=a, dotted = 2nd half)')
    subplot1(sp4); hold off; plot(X,atime(res2<99,1)/10,'b',X,btime(res2<99,1)/10+30,'r'); 
    subplot1(sp4); hold on;  plot(X,atime(res2<99,end)/10,'b:',X,btime(res2<99,end)/10+30,'r:'); 
    subplot1(sp4); hold on; xl=xlim; yl=ylim; text(xl(1)+1,yl(end)-10,'(red=b, blue=a, dotted = 2nd half)')
  end
