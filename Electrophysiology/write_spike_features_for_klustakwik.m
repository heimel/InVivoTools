function write_spike_features_for_klustakwik( cells, record )
%WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK
%
%    WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK( CELLS, RECORD )
%
% 2013, Alexander Heimel
%

if nargin<2
    record = [];
end

if isempty(record)
    datapath = pwd;
else
    datapath = ecdatapath(record);
end

params = ecprocessparams;

flds = fields(cells);
ind = strmatch('spike_',flds);

if ~any(isnan(flatten({cells(:).spike_lateslope})))
   use_lateslope = true;
else
    use_lateslope = false;
end

features = {flds{ind}};
n_features = length(ind);
if ~use_lateslope
    n_features = n_features - 1;
end
n_cells = length(cells);
% plot clusters

filenamef = fullfile(datapath,record.test,[ 'klustakwik.fet.1']);
fidf = fopen(filenamef,'w');
if fidf==-1
    disp(['WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK: Cannot open ' filenamef ' for writing']);
    return
else
    disp(['WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK: Writing spike features to ' filenamef]);
end


filenamet = fullfile(datapath,record.test,[ 'klustakwik.tim.1']);
fidt = fopen(filenamet,'w');
if fidt==-1
    disp(['WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK: Cannot open ' filenamet ' for writing']);
    return
end


addnoise = 0;
if addnoise
    warning('ADDING ARTIFICIAL NOISE BEFORE CLUSTERING');
end


fprintf(fidf,'%d\n',n_features); % file starts with number of features
for c=1:n_cells
    n_spikes = length(cells(c).data);
    for i=1:n_spikes
        fprintf(fidt,'%f\n',cells(c).data(i)); % spike time
        %         for f=1:n_features
        %             fprintf(fidf,'%f ',cells(c).(features{f})(i));  % features
        %         end
        fprintf(fidf,'%0d ',round(cells(c).spike_amplitude(i) + addnoise*rand(1)*100)  );
        fprintf(fidf,'%f ',cells(c).spike_trough2peak_time(i) + addnoise*rand(1)*0.05  );
        fprintf(fidf,'%f ',cells(c).spike_peak_trough_ratio(i) + addnoise*rand(1)*0.1 );
        fprintf(fidf,'%f ',cells(c).spike_prepeak_trough_ratio(i) + addnoise*rand(1)*0.1);
        if use_lateslope
            fprintf(fidf,'%0d',round(cells(c).spike_lateslope(i)+ addnoise*rand(1)*50  ));
        end
        fprintf(fidf,'\n');
    end
end

fclose(fidf);
fclose(fidt);
