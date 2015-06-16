function outcells = import_klustakwik( record, orgcells )
%IMPORT_KLUSTAKWIK import klustakwik clu file
%
% OUTCELLS = IMPORT_KLUSTAKWIK( RECORD, ORGCELLS)
%
% 2013-2014, Alexander Heimel
%

outcells = [];

if nargin<1
    record = [];
end

if isempty(record)
    datapath = pwd;
else
    datapath = experimentpath(record,false);
end

channels = unique([orgcells.channel]);

intervals = [];
sample_interval = [];

channels_new_index = (0:1000)*10+1; % works for up to 1000 channels, and max 10 cells per channel

if ~isempty( orgcells )
    intervals = orgcells(1).intervals;
    sample_interval = orgcells(1).sample_interval;
end

count = 1;

flds = fields(orgcells);
ind = strmatch('spike_',flds);
features = flds(ind);
if ~any(isnan(flatten({orgcells(:).spike_lateslope})))
    use_lateslope = true;
else
    use_lateslope = false;
end

if ~use_lateslope
    features = setdiff(features,'spike_lateslope');
end
n_features = length(features);


for ch = channels
    filenamec = fullfile(datapath,record.test,[ 'klustakwik.clu.' num2str(ch)]);
    fidc = fopen(filenamec,'r');
    if fidc==-1
        logmsg(['Cannot open ' filenamec ' for reading']);
        return
    end
    
    
    filenamef = fullfile(datapath,record.test,[ 'klustakwik.fet.' num2str(ch)]);
    fidf = fopen(filenamef,'r');
    if fidf==-1
        logmsg(['Cannot open ' filenamef ' for reading']);
         fclose(fidc);
        return
    end
    
    n_fet = str2double(fgetl(fidf)); % number of features
    
    filenamet = fullfile(datapath,record.test,[ 'klustakwik.tim.' num2str(ch)]);
    fidt = fopen(filenamet,'r');
    if fidt==-1
        logmsg(['Cannot open ' filenamet ' for reading']);
         fclose(fidc);
         fclose(fidf);
        return
    end
    
    
    n_spikes = 0;
    for i=1:length(orgcells);
        n_spikes = n_spikes+ length(orgcells(i).data);
    end
    
    cells = [];
    logmsg('Loading Klustakwik assignments.');
    spikecount = zeros(100,1);
    cellnumber = nan(n_spikes,1);
    i = 1;
    fgetl(fidc); % extra line????, but necessary
    while(~feof(fidc))
        c = fscanf(fidc,'%d',1);
        if isempty(c)
            logmsg('Too few spikes assigned?');
        else
            cellnumber(i) =  c;
            %        cellnumber(end+1) = str2double( fgets(fidc));
            spikecount(cellnumber(i)) =  spikecount(cellnumber(i))+1;
            i = i+1;
        end
    end
    logmsg(['Imported ' num2str(i-1) ' assignments']);
    cellnumber(i:end) = [];
    fclose(fidc);
    logmsg('Loading Klustakwik data');

    cellnumbers = find(spikecount>0);
    for c=cellnumbers(:)'
        cells(c).data = zeros(spikecount(c),1);
        cells(c).spike_amplitude = zeros(spikecount(c),1);
        cells(c).spike_trough2peak_time = zeros(spikecount(c),1);
        cells(c).spike_peak_trough_ratio = zeros(spikecount(c),1);
        cells(c).spike_prepeak_trough_ratio = zeros(spikecount(c),1);
        cells(c).spike_lateslope = zeros(spikecount(c),1);
    end
    
    spikecount = ones(100,1);

    for i=1:length(cellnumber)
        if feof(fidt)
            logmsg(['Premature end to ' filenamet 'at line number ' num2str(i)]);
            fclose(fidt);
         fclose(fidf);

            return
        end
        c = cellnumber(i);
        cells(c).data(spikecount(c),1) = str2double( fgets(fidt));
        for f = 1:n_features
            cells(c).(features{f})(spikecount(c),1) = fscanf(fidf,'%f',1); 
        end
        
%         cells(c).spike_amplitude(spikecount(c),1) = fscanf(fidf,'%f',1); % was %d
%         cells(c).spike_trough2peak_time(spikecount(c),1) = fscanf(fidf,'%f',1);
%         cells(c).spike_peak_trough_ratio(spikecount(c),1) = fscanf(fidf,'%f',1);
%         cells(c).spike_prepeak_trough_ratio(spikecount(c),1) = fscanf(fidf,'%f',1);
%         if n_fet>4
%             cells(c).spike_lateslope(spikecount(c),1) = fscanf(fidf,'%f',1); % was %d
%         end
        spikecount(c) = spikecount(c)+1;
    end
    fclose(fidt);
    fclose(fidf);
        
    for cl=1:length(cells)
        if cells(cl).data<10 % don't include cells with less than 10 spikes
            continue
        end
        
        outcells(count).index = channels_new_index(ch); %#ok<*AGROW> % used to identify cell
        channels_new_index(ch) = channels_new_index(ch) + 1;
        outcells(count).name = sprintf('cell_%s_%.3d',...
            subst_specialchars(record.test),outcells(count).index);
        outcells(count).data = cells(cl).data;
        outcells(count).channel = ch;
        outcells(count).intervals = intervals;
        outcells(count).sample_interval = sample_interval;
        outcells(count).desc_long = experimentpath(record);
        outcells(count).desc_brief = record.test;
        outcells(count).detector_params = [];
        outcells(count).trial = record.test;
        outcells(count).wave = zeros(1,32);
        outcells(count).std = zeros(1,32);
        outcells(count).snr = NaN;
        for f = 1:n_features
            outcells(count).(features{f}) = cells(cl).(features{f}); 
        end
        outcells(count).mean_amplitude = mean(outcells(count).spike_amplitude);
        count = count + 1;
    end
    % sort by spike amplitude from low to high
    indices = [ outcells.index];
    [m,ind] = sort([outcells.mean_amplitude]);
    outcells = outcells(ind);
    for i = 1:length(outcells)
        outcells(i).index = indices(i);
    end
end % channel ch


