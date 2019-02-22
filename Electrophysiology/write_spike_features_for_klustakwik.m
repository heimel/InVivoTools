function write_spike_features_for_klustakwik( allcells, record, channels )
%WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK
%
%    WRITE_SPIKE_FEATURES_FOR_KLUSTAKWIK( CELLS, RECORD )
%
% 2013-2015, Alexander Heimel
%

if nargin<3 || isempty(channels)
    channels = unique([allcells.channel]);
end

if nargin<2 || isempty(record)
    datapath = pwd;
else
    datapath = experimentpath(record,false);
end

lineend = '\r\n';

params = ecprocessparams(record);

flds = fieldnames(allcells);
ind = strmatch('spike_',flds);
features = flds(ind);

if ~any(isnan(flatten({allcells(:).spike_lateslope})))
    use_lateslope = true;
else
    use_lateslope = false;
end

if ~use_lateslope
    features = setdiff(features,'spike_lateslope');
end
n_features = length(features);

addnoise = 0;



for ch=channels
    cells = allcells([allcells.channel]==ch);
    n_cells = length(cells);
    
    if isfield(record,'test')
        test = record.test;
    else
        test = record.epoch;
    end
    
    filenamef = fullfile(datapath,test,[ 'klustakwik.fet.' num2str(ch)]);
    fidf = fopen(filenamef,'W');
    if fidf==-1
        errormsg(['Cannot open ' filenamef ' for writing']);
        return
    else
        logmsg(['Writing spike features to ' filenamef]);
    end
    
    
    filenamet = fullfile(datapath,test,[ 'klustakwik.tim.' num2str(ch)]);
    fidt = fopen(filenamet,'W');
    if fidt==-1
        fclose(fidf);
        errormsg(['Cannot open ' filenamet ' for writing']);
        return
    end
    
    if addnoise
        logmsg('Adding artificial noise before clustering. Should be avoided');
    end
        
    fprintf(fidf,'%d',n_features); % file starts with number of features
    fprintf(fidf,lineend);

    st =  'fprintf(fidf,[''';
    for f = 1:n_features
        st = [st '%f '];
    end
    st = [st ' '' lineend]'];
    for f = 1:n_features
        st = [st ',cells(c).(features{' num2str(f) '})(i)'];
    end
    st = [st ');'];

    
     for c=1:n_cells
         n_spikes = length(cells(c).data);
             fprintf(fidt,['%f' lineend],cells(c).data); % spike time
        for i=1:n_spikes
        %    fprintf(fidt,['%f' lineend],cells(c).data(i)); % spike time
             
%             for f = 1:n_features
%                 fprintf(fidf,'%f ',cells(c).(features{f})(i) + addnoise*rand(1)*0.01  );
%             end % feature f
%             fprintf(fidf,lineend);
%     fprintf(fidf,['%f %f %f %f %f %f %f ' lineend],...
%         cells(c).(features{1})(i),...
%         cells(c).(features{2})(i),...
%         cells(c).(features{3})(i),...
%         cells(c).(features{4})(i),...
%         cells(c).(features{5})(i),...
%         cells(c).(features{6})(i),...
%         cells(c).(features{7})(i));
        eval(st);
        end % spike i
    end % cell c
    
    fclose(fidf);
    fclose(fidt);
end