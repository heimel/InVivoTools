function WaveTime_Fpikes = load_kilosort_data(strTarget,EVENT)

%get SF and nChan
sampF = max([EVENT.strms.sampf]);
nChan = EVENT.strms(1).channels;

%load unit info
fs = dir(fullfile(strTarget, '*groups.csv'));
fs2 = dir(fullfile(strTarget,'*group.tsv'));

if ~isempty(fs)
    loadf = fullfile(strTarget,'cluster_groups.csv');
    ops = detectImportOptions(loadf);
    unitspecs = readtable(loadf, ops);
    unitspecs = table2cell(unitspecs);
elseif ~isempty(fs2)
    loadf2 = fullfile(strTarget,'cluster_group.tsv');
     [data,header,unitspecs] =tsvread(loadf2);
    for i=2:size(unitspecs,1)
        unitspecs{i,1} = str2num(unitspecs{i,1}); 
    end
    unitspecs(1,:) = [];
else  % no curated data
    unitspecs = [];
end
  


%load spike times
sp = loadKSdir(strTarget);
locSpikesOnly = false;
[spikeTimes, spikeAmps, spikeDepths, spikeSites] = ksDriftmap(strTarget, locSpikesOnly);


% %put spikes in data struct
allclu = sort(unique(sp.clu));
unitCounter = 0;
checkchan = 1;

%first load the raw data
cd(strTarget)
myfile = fullfile('*.bin');
s = dir(myfile);
myfilesize = s.bytes;

%antigua recordings have 16 channels typically
k1 = strfind(strTarget,'Antigua');
k2 = strfind(strTarget,'antigua');

if (length(k1)+length(k2)) > 0
    nChan = 16;
    nSamp = myfilesize./(2*nChan);
    checkchan = 0;
end

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

%if data is manually curated, take individual good units
if ~isempty(unitspecs)
    for cl = 1:length(allclu)
        clus = allclu(cl);
        
        % see if cluster is single unit
        specInd = find([unitspecs{:,1}]==clus);
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
        WaveTime_Fpikes(unitCounter).amplitude = mySpikeAmps;
        
        %also get waveforms
        mmf = memmapfile(fullfile(strTarget,s.name), 'Format', {'int16', ...
            [nChan nSamp], 'x'});
        
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
else  %if data is not curated, take the units for each channel
    
    chSites = [];
    for cl = 1:length(allclu)
        %check which channel each cluster is located at
        clus = allclu(cl);
        chSpikeSites = spikeSites(sp.clu ==clus);
        chSites(cl) = median(chSpikeSites);
    end
   for ch = 1:nChan
        clusters = allclu(chSites==ch);

        % get the spike times etc. only for desired clusters
        mySpikeSites = spikeSites(ismember(sp.clu ,clusters));
        mySpikeSite = median(mySpikeSites);
        mySpikeTimes = spikeTimes(ismember(sp.clu,clusters)); %in seconds
        mySpikeAmps = spikeAmps(ismember(sp.clu,clusters));
        WaveTime_Fpikes(ch).time = mySpikeTimes;
        WaveTime_Fpikes(ch).channel = mySpikeSite;
        WaveTime_Fpikes(ch).amplitude = mySpikeAmps;
        
        %also get waveforms
        mmf = memmapfile(fullfile(strTarget,s.name), 'Format', {'int16', ...
            [nChan nSamp], 'x'});
        
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
            WaveTime_Fpikes(ch).data(i,:) = double(tempWF);
        end
    end 
end


end