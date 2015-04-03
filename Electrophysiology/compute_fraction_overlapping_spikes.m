function compute_fraction_overlapping_spikes( record )
%COMPUTE_FRACTION_OVERLAPPING_SPIKES return the fraction of spikes counted on two channels
%
% 2014, Alexander Heimel
%

bin = 0.001;

datapath = experimentpath(record);
if ~exist(fullfile(datapath,'_spikes.mat'),'file')
    return
end
load(fullfile(datapath,'_spikes.mat'));
if  ~isfield(cells,'channel')
    logmsg(['No channel field in spikes file. Need to reanalyse ' recordfilter(record)]);
    return
end
    
    
loaded_channels = uniq(sort([cells.channel]));

[recorded_channels,area] = get_recorded_channels( record ); %#ok<ASGLU>

for i=1:length(area)
    channels = intersect(area(i).channels,loaded_channels);
    spiketimes = [];
    spikechannels = [];
    for ch=channels
        ind = find( [cells.channel]==ch);
        spikes = cat(1,cells(ind).data);
        spiketimes = [spiketimes; spikes];
        spikechannels = [spikechannels; ch*ones(size(spikes))];
    end
    [spiketimes,ind] = sort(spiketimes);
    spikechannels = spikechannels(ind);
    spikediff = diff(spiketimes);
    ind = find(spikediff<bin); % spikes within 1 ms
    
    on_same_channel = sum(spikechannels(ind)-spikechannels(ind+1)==0);
    on_neighboring_channels = sum(abs(spikechannels(ind)-spikechannels(ind+1))==1);
    on_next_neighboring_channels = sum(abs(spikechannels(ind)-spikechannels(ind+1))==2);
    on_nnext_neighboring_channels = sum(abs(spikechannels(ind)-spikechannels(ind+1))==3);
    on_nnnext_neighboring_channels = sum(abs(spikechannels(ind)-spikechannels(ind+1))==4);
    
    logmsg(['Area = ' area(i).name ', Channels = ' mat2str(channels)]);
    logmsg(['Total spikes = ' num2str(length(spiketimes))  ]);
    logmsg(['Spikes within ' num2str(bin) ' s on same channel = ' num2str(on_same_channel) ]);
    logmsg([' on neighboring channels = ' num2str(on_neighboring_channels) ]);
    logmsg([' on next neighboring channels = ' num2str(on_next_neighboring_channels) ]);
    logmsg([' on next next neighboring channels = ' num2str(on_nnext_neighboring_channels) ]);
    logmsg([' on next next next neighboring channels = ' num2str(on_nnnext_neighboring_channels) ]);
    logmsg(['Percentage counted possibly twice: ' num2str(on_neighboring_channels/length(spiketimes)*100,2) ' %']);
end

function [recorded_channels,area] = get_recorded_channels( record )
recorded_channels = [];
area = [];
if isfield(record,'channel_info') && ~isempty(record.channel_info)
    channel_info = split(record.channel_info);
    if length(channel_info)==1
        recorded_channels = sort(str2num(channel_info{1})); %#ok<ST2NM>
    else
        for i=1:2:length(channel_info)
            area( (i+1)/2 ).channels = sort(str2num(channel_info{i})); %#ok<ST2NM,AGROW>
            area( (i+1)/2 ).name = lower(channel_info{i+1}); %#ok<AGROW>
            if ~isempty(intersect(recorded_channels,area( (i+1)/2 ).channels))
                errormsg('There is a channel assigned to two areas');
                return
            end
            recorded_channels = [recorded_channels area( (i+1)/2 ).channels]; %#ok<AGROW>
        end
        recorded_channels = sort( recorded_channels );
    end
end
