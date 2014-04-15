% erg_getdata_avg: retrieves/computes mean data, at the moment it is only
% functional for pulsetrain blocks. It uses caching and depends on
% erg_getdata_raw for its data.
%
% This file works on a multi-channel basis: channels_avg returns a cell
% containing a struct for each channel. This struct contains all responses and
% the amount of samples removed.

function [channels_avg stims prepulse_period] = erg_getdata_avg(filename, mode)
graphs = 0; % 1 to show extra figures

global ergConfig;
channels_avg = {};

if (nargin < 2) 
    mode = 1; 
end

%check if a cache version is available..
cache_filename = [filename(1:end-8) 'CACHE_AVG.mat'];
if ~ergConfig.recompute && (ergConfig.getdata_cache_load_avg && exist(cache_filename,'file'))
    load(cache_filename);
    return;
end

data = erg_getdata_raw(filename);
for chan = 1:data.block.numchannels
    switch mode
        case 1
            dataForThisChannel = data.(['results' num2str(chan)]);
            Srt = sortrows([data.stimuli; dataForThisChannel']')';
            dataset = -1.*Srt(4:size(Srt,1),:)';
            d = data.block.data4type.pulsetrain;
            
            prepulse_period = str2num(d.prepulse);
            sweeps_size  = str2num(d.numrepeats);
            sweeps_count = str2num(d.pulse_steps);
            for (i = 1:sweeps_count)
                [resultset(i,:), nRemoved(i)] = erg_analysis_avgpulse(dataset((i-1)*sweeps_size+1:i*sweeps_size,:),graphs);
                stims(i) = Srt(2,i*sweeps_size);
            end
            avg.resultset = resultset;
            avg.nRemoved = nRemoved;
            channels_avg{chan} = avg;
    end
end

%Save cache, depending on config setting
if (ergConfig.getdata_cache_save_avg)
    save(cache_filename,'channels_avg','stims','prepulse_period');
end

