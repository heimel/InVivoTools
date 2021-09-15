function f = make_kilosort_data(EVENT, strTarget,channels2analyze)
%MAKE_KILOSORT_DATA gets raw tdt continously sampled data and runs kilosort
%


if nargin<3 || isempty(channels2analyze)
    channels2analyze = 1:EVENT.snips.Snip.channels;
end

% get raw data
EVENT.Myevent = 'RAW_';
EVENT.Start = 0; %s
EVENT = getMetaDataTDT(EVENT);
[vecTimestamps,~,vecChannels] = getRawDataTDT_invivo(EVENT,[],channels2analyze);
% if length(vecTimestamps)>size(matData,2)
%     vecTimestamps(size(matData,2)+1:end)=[];
% end
save(fullfile(strTarget,'rawdataTimestamps.mat'), 'vecTimestamps')

%now run kilosort
fprintf('Now running spike sorting on Kilosort.. \n')
runKilosort_invivo(EVENT, strTarget,channels2analyze)

%message
f = msgbox([ 'Kilosort has sorted the spikes. They still need to be manually '...
    'curated. Use python to curate the spikes and click the analysis button again to plot the results']);

return
