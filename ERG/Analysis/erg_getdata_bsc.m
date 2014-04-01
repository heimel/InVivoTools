% erg_getdata_bsc: retrieves/calculates basic erg curve parameters. Uses
% cache files when indicated in ergConfig.getdata_cache_load_bsc and
% ..save_bsc.
%
% This file works on a multi-channel basis: channel_bsc is a cell
% containing a struct per channel. This struct contains things such as
% bwave-amplitude.

function [channel_bsc prepulse_samples stims] = erg_getdata_bsc(filename)
global ergConfig;

cache_filename = [filename(1:end-8) 'CACHE_BSC.mat'];
if  ~ergConfig.recompute && (ergConfig.getdata_cache_load_bsc && exist(cache_filename,'file'))
    load(cache_filename);
    return;
end

[channel_avg, stims, prepulse_period] = erg_getdata_avg(filename);
[block duration stimuli] = erg_getdata_div(filename);

totsamples = size(channel_avg{1}.resultset,2);
prepulse_samples = min([totsamples, prepulse_period*(totsamples/duration)]);

for (chan = 1:block.numchannels)
    figure('Name',['Waves - channel ' num2str(chan)],'NumberTitle','off')
    avg = channel_avg{chan};
    subplot1(4,ceil(size(avg.resultset,1)/4),'Gap',[0 0],'XTickL','Margin','YTickL','Margin');
    for (i = 1:size(avg.resultset,1))
        subplot1(i);
        [bsc.baseline(i) bsc.awave(i) bsc.atime(i) bsc.bwave(i) bsc.btime(i)] = erg_analysis_getab(avg.resultset(i,:), prepulse_samples, duration);
    end
    for i = (size(avg.resultset,1)+1):(ceil(size(avg.resultset,1)/4)*4)
        subplot1(i);
        axis off
    end
    channel_bsc{chan} = bsc;
end

if (ergConfig.getdata_cache_save_bsc)
    save(cache_filename,'channel_bsc', 'prepulse_samples', 'stims');
end
