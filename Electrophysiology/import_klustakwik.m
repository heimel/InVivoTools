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

% channels_new_index = (0:1000)*10+1; % works for up to 1000 channels, and max 10 cells per channel

if ~isempty( orgcells )
    intervals = orgcells(1).intervals;
    sample_interval = orgcells(1).sample_interval;
end

count = 1;

flds = fieldnames(orgcells);
features = flds(strncmp('spike_',flds,6));
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
    if n_features ~= n_fet
        logmsg(['Discrepancy in number of features in ' filenamef]);
    end
    
    filenamet = fullfile(datapath,record.test,[ 'klustakwik.tim.' num2str(ch)]);
    fidt = fopen(filenamet,'r');
    if fidt==-1
        logmsg(['Cannot open ' filenamet ' for reading']);
        fclose(fidc);
        fclose(fidf);
        return
    end
    spiketimes = fscanf(fidt,'%f',inf);
    fclose(fidt);
    
    n_spikes = 0;
    for i=1:length(orgcells)
        n_spikes = n_spikes+ length(orgcells(i).data);
    end
    
    cells = [];
    logmsg('Loading Klustakwik assignments.');
    
    n_cells = fscanf(fidc,'%d',1); % number of clusters
    cellnumber = fscanf(fidc,'%d',inf);
    fclose(fidc);
    
    logmsg(['Imported ' num2str(length(cellnumber)) ' spike assignments to ' num2str(n_cells) ' cells.']);
    if length(cellnumber)~=n_spikes
        logmsg('Number of imported spikes differs from original number');
    end
    
    
    featuresdata = fscanf(fidf,'%f',[n_features,length(cellnumber)]);
    fclose(fidf);
    if ~all(size(featuresdata)==[n_features,length(cellnumber)])
        errormsg('Problem with reading in feature file. Incorrect number of spikes or features',true);
    end
    
    
    for c = 1:n_cells
        cells(c).ind_spike = find(cellnumber==c);
        n_spikes = length(cells(c).ind_spike);
        cells(end).data = spiketimes(cells(c).ind_spike);
        cells(end).spike_amplitude = zeros(n_spikes,1);
        cells(end).spike_trough2peak_time = zeros(n_spikes,1);
        cells(end).spike_peak_trough_ratio = zeros(n_spikes,1);
        cells(end).spike_prepeak_trough_ratio = zeros(n_spikes,1);
        cells(end).spike_lateslope = zeros(n_spikes,1);
        for f = 1:n_features
            cells(end).(features{f})(:,1) = featuresdata(f,cells(c).ind_spike);
        end
    end % cell c
    
    for cl=1:n_cells % on this channel
        if cells(cl).data<10 % don't include cells with less than 10 spikes
            continue
        end
        
        %         outcells(count).index = channels_new_index(ch); %#ok<*AGROW> % used to identify cell
        %         channels_new_index(ch) = channels_new_index(ch) + 1;
        %         outcells(count).name = sprintf('cell_%s_%.3d',...
        %             subst_specialchars(record.test),outcells(count).index);
        outcells(count).data = cells(cl).data;
        outcells(end).channel = ch;
        outcells(end).intervals = intervals;
        outcells(end).sample_interval = sample_interval;
        %         outcells(count).desc_long = experimentpath(record);
        %         outcells(count).desc_brief = record.test;
        %         outcells(count).detector_params = [];
        %         outcells(count).trial = record.test;
        outcells(end).spikes = orgcells(find(channels==ch,1)).spikes(cells(cl).ind_spike,:);
        outcells(end).wave = mean(outcells(end).spikes,1);
        outcells(end).std = std(outcells(end).spikes,1);
        %         outcells(count).snr = NaN;
        outcells(end).ind_spike = cells(cl).ind_spike;
        for f = 1:n_features
            outcells(end).(features{f}) = cells(cl).(features{f});
        end
        outcells(end).mean_amplitude = mean(outcells(count).spike_amplitude);
        count = count + 1;
    end % cell cl
    
end % channel ch


