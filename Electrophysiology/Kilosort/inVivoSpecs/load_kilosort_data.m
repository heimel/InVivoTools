function WaveTime_Fpikes = load_kilosort_data(strTarget,EVENT)

%get SF and nChan
sampF = max([EVENT.strms.sampf]);
nChan = EVENT.strms(1).channels;

%load unit info
loadf = fullfile(strTarget,'cluster_groups.csv');
ops = detectImportOptions(loadf);
unitspecs = readtable(loadf, ops);
unitspecs = table2cell(unitspecs);
%load spike times
sp = loadKSdir(strTarget);
locSpikesOnly = false;
[spikeTimes, spikeAmps, spikeDepths, spikeSites] = ksDriftmap(strTarget, locSpikesOnly);


%put spikes in data struct
allclu = sort(unique(sp.clu));
unitCounter = 0;
checkchan = 1;

%get corrfac if present
files = dir(strTarget);
if ~isempty(find(strcmpi({files.name},'corrfac.mat')));
    load(fullfile(strTarget,'corrfac.mat'));  
end

for cl = 1:length(allclu)
    clus = allclu(cl);
    specInd = find([unitspecs{:,1}]==clus);
    % see if cluster is single unit
    if ~strcmp(unitspecs(specInd,2),'good')
        continue
    end
    
    unitCounter = unitCounter +1 ;
    
    
    
    % get the spike times etc. only for desired cluster
    mySpikeSites = spikeSites(sp.clu ==clus);
    mySpikeSite = median(mySpikeSites);
    mySpikeTimes = spikeTimes(sp.clu==clus); %in seconds
    WaveTime_Fpikes(unitCounter).time = mySpikeTimes;
    WaveTime_Fpikes(unitCounter).channel = mySpikeSite;
    
    %also get waveforms
    %first load the raw data
    cd(strTarget)
    myfile = fullfile('*.bin');
    s = dir(myfile);
    myfilesize = s.bytes;
    
    %     nSamp = myfilesize./(2*nChan); %2 bytes per int16 value
    %double check how many channels are there
    if checkchan==1 %only ask once
        findch = nan(1,32);
        for i=1:32
            samp = myfilesize./(2*i);
            findch(i) = samp - floor(samp) == 0;
        end
        possib = find(findch);
        Q = 'How many channels are in the recording?';
        choice = menu(Q,num2cell(possib));
        nChan = possib(choice);
        nSamp = myfilesize./(2*nChan);
        checkchan = 0;
    end
    
    
    mmf = memmapfile(fullfile(strTarget,s.name), 'Format', {'int16', ...
        [nChan nSamp], 'x'});
end

%extract the waveforms
spikesToExtract = round(mySpikeTimes*sampF);
%     extractST = theseST(1:min(100,length(spikesToExtract))); %extract at most the first 100 spikes
nWFsToLoad = length(spikesToExtract);
wfWin = [-14:15]; % samples around the spike times to load
nWFsamps = length(wfWin);
theseWF = zeros(nWFsToLoad, nWFsamps);
for i=1:nWFsToLoad
    tempWF = ...
        mmf.Data.x(mySpikeSite,spikesToExtract(i)+wfWin(1):spikesToExtract(i)+wfWin(end));
    WaveTime_Fpikes(unitCounter).data(i,:) = double(tempWF);
end

end