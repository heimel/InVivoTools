function f = make_kilosort_data(EVENT, strTarget)

% get raw data
EVENT.Myevent = 'RAW_';
EVENT.Start = 0; %s
EVENT = getMetaDataTDT(EVENT);
[vecTimestamps,matData,vecChannels] = getRawDataTDT(EVENT);
%correct voltage dir
matData = -matData;

%write raw data to binary file
strTargetFile = fullfile(EVENT.Mytank, EVENT.Myblock,'RawBinData.bin');
ptrFile = fopen(strTargetFile,'w');
fprintf('Writing data to binary file "%s"... \n',strTargetFile);
intCount = fwrite(ptrFile, matData,'int16');
fclose(ptrFile);
fprintf('Done! Output is %d \n',intCount);

%now run kilosort
fprintf('Now running spike sorting on Kilosort.. \n')
runKilosort_invivo(EVENT, strTarget)

%message
f = msgbox([ 'Kilosort has sorted the spikes. They still need to be manually '...
    'curated. Use python to curate the spikes and click the analysis button again to plot the results']);

return
