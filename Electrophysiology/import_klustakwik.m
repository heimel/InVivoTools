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
    datapath = ecdatapath(record);
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
        return
    end
    
    n_fet = str2double(fgetl(fidf)); % number of features
    
    filenamet = fullfile(datapath,record.test,[ 'klustakwik.tim.' num2str(ch)]);
    fidt = fopen(filenamet,'r');
    if fidt==-1
        logmsg(['Cannot open ' filenamet ' for reading']);
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
    for c=cellnumbers
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
            return
        end
        c = cellnumber(i);
        cells(c).data(spikecount(c),1) = str2double( fgets(fidt));
        cells(c).spike_amplitude(spikecount(c),1) = fscanf(fidf,'%f',1); % was %d
        cells(c).spike_trough2peak_time(spikecount(c),1) = fscanf(fidf,'%f',1);
        cells(c).spike_peak_trough_ratio(spikecount(c),1) = fscanf(fidf,'%f',1);
        cells(c).spike_prepeak_trough_ratio(spikecount(c),1) = fscanf(fidf,'%f',1);
        if n_fet>4
            cells(c).spike_lateslope(spikecount(c),1) = fscanf(fidf,'%f',1); % was %d
        end
        spikecount(c) = spikecount(c)+1;
    end
    fclose(fidt);
    fclose(fidf);
    
    
    %     try
    %         cksds=cksdirstruct(ecdatapath(record));
    %     catch
    %         disp(['IMPORTSPIKE2: Could not create/open cksdirstruct ' path])
    %         return
    %     end
    %
    %     % load acquisitionfile for electrode name
    %     % to get samplerate acqParams_out should be used instead of _in
    %     ff=fullfile(getpathname(cksds),trial,'acqParams_in');
    %     f=fopen(ff,'r');
    %     if f==-1
    %         disp(['Error: could not open ' ff ]);
    %         return;
    %     end
    %     fclose(f);  % just to get proper error
    %     acqinfo=loadStructArray(ff);
    %
    %
    %     unitchannelname = 'Spikes';
    
    % cellnamedel=sprintf('cell_%s_%s_%.4d_*',acqinfo(1).name,unitchannelname,acqinfo(1).ref);
    % deleteexpvar(cksds,cellnamedel); % delete all old representations
    % [px,expf] = getexperimentfile(cksds,1);
    % delete(px);
    % [px,expf] = getexperimentfile(cksds,1);
    
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
        outcells(count).desc_long = fullfile(ecdatapath(record),record.test);
        outcells(count).desc_brief = record.test;
        outcells(count).detector_params = [];
        outcells(count).trial = record.test;
        outcells(count).wave = zeros(1,32);
        outcells(count).std = zeros(1,32);
        outcells(count).snr = NaN;
        outcells(count).spike_amplitude = cells(cl).spike_amplitude;
        outcells(count).spike_trough2peak_time = cells(cl).spike_trough2peak_time;
        outcells(count).spike_peak_trough_ratio = cells(cl).spike_peak_trough_ratio;
        outcells(count).spike_prepeak_trough_ratio = cells(cl).spike_prepeak_trough_ratio;
        outcells(count).spike_lateslope = cells(cl).spike_lateslope;
        count = count + 1;
    end
    
end % channel ch


