function record = analyse_ectestrecord(record,verbose,allowchanges)
%ANALYSE_ECTESTRECORD runs all analysis on electrophysiology testrecord
%
%   RECORD = ANALYSE_ECTESTRECORD( RECORD, VERBOSE=true, ALLOWCHANGES=true )
%
%       if ALLOWCHANGES is false, then no changes to any stored files are made
%
% 2007-2017, Alexander Heimel, Mehran Ahmadlou

if nargin<3 || isempty(allowchanges)
    allowchanges = true; 
end

if nargin<2 || isempty(verbose)
    verbose = true;
end

if strcmp(record.datatype,'ec')~=1
    errormsg(['datatype ' record.datatype ' is not implemented.']);
    return
end

if isfield(record,'monitorpos') && isempty(record.monitorpos)
    errormsg(['Monitor position is missing in record. mouse=' record.mouse ',date=' record.date ',test=' record.test]);
end

datapath=experimentpath(record,false);
if ~exist(datapath,'dir')
    errormsg(['Folder ' datapath ' does not exist.']);
    return
end

% per date one cksdirstruct to conform to Nelsonlab practice
cksds = cksdirstruct(datapath);

processparams = ecprocessparams(record);

[recorded_channels,area] = get_recorded_channels( record );
channels2analyze = get_channels2analyze( record );
if isempty(channels2analyze)
    channels2analyze = recorded_channels;
end

cells = import_spikes( record, channels2analyze, verbose, allowchanges ); 

if isempty(cells)
    return
end

% now compute responses to stimuli

if isfield(record,'test')
    test = record.test;
else
    test = record.epoch;
end
ssts = getstimscripttimestruct(cksds,test);

if isfield(record,'stimscript') && isempty(record.stimscript)
    % fill in stimscript class
    stims = getstimsfile(record);
    if isempty(stims)
        return
    end
    record.stimscript = class(stims.saveScript(1));
end

measures=[];

g = getcells(cksds);
if isempty(g)
    return
end
loadstr = ['''' g{1} ''''];
for i=2:length(g)
    loadstr = [loadstr ',''' g{i} '''']; %#ok<AGROW>
end
eval(['d = load(getexperimentfile(cksds),' loadstr ',''-mat'');']);

if length(g)>50 % dont show more than 10 cells in the analysis
    logmsg('More than 10 cells, going into silence mode');
    verbose = 0;
end

for i=1:length(g) % for all cells
    switch record.stim_type
        case {'sg','sg_adaptation'}
            inp.stimtime = stimtimestruct(ssts,1); % only works for one repetition
    end
    
    inp.st=ssts;
    inp.spikes={};
    inp.cellnames = {};
    inp.spikes=d.(g{i});
    n_spikes=0;
    for k=1:length(ssts.mti)
        try
            n_spikes=n_spikes+length(get_data(inp.spikes,...
                [ssts.mti{k}.startStopTimes(1),...
                ssts.mti{k}.startStopTimes(end)],1));
        catch me
            logmsg(['An error is caught. I do not know why. Tell Alexander to check. ' me.message]);
            n_spikes=n_spikes+length(get_data(inp.spikes,...
                [ssts.mti{k}.startStopTimes(1),...
                ssts.mti{k}.startStopTimes(end-1)]));
        end
    end
    inp.cellnames{1} = [g{i}];
    inp.title=[g{i}]; % only used in period_curve
    logmsg(['Cell ' num2str(i) ' of ' num2str( length(g) ) ...
        ', ' g{i} ', ' num2str(n_spikes) ' spikes']);
    
    stim_type = record.stim_type;
    try
        stim = get(inp.st.stimscript);
        if ~isempty(stim)
            switch class(stim{1})
                case 'stochasticgridstim'
                    stim_type = 'sg';
            end
        end
    catch me
        logmsg(['Warning: ' me.message]);
    end
    
    if ~isempty(inp.st) && ~isempty(inp.st.stimscript)
        switch stim_type
            case {'sg','sg_adaptation'}
                cellmeasures = analyse_sg(inp,n_spikes,record,verbose);
            case {'hupe','border','lammemotion','lammetexture'}
                cellmeasures = analyse_ectest_by_typenumber(inp,record);
            otherwise
                cellmeasures = analyse_ps(inp,record,verbose);
        end
        if ~isfield(cellmeasures,'usable')
            cellmeasures.usable = 1;
        end
    else
        cellmeasures.usable = 0;
    end
    
    if ~isempty(find_record(record,['comment=*' num2str(i) ':axon*']))
        cellmeasures.usable=0;
    end
    
    if ~isempty(find_record(record,['comment=*' num2str(i) ':bad*']))
        cellmeasures.usable=0;
    end
    
%     if isempty(measures)
%         cellmeasures.type='mu';
%     else
%         cellmeasures.type='su';
%     end
    
    if isfield(cellmeasures,'rate_peak') && isfield(cellmeasures,'rate_spont')
        cellmeasures.ri= (cellmeasures.rate_peak-cellmeasures.rate_spont) /...
            cellmeasures.rate_peak;
    end
    if isfield(cellmeasures,'rate_max') && isfield(cellmeasures,'rate_spont')
        % compute signal to noise ratio (don't confuse with cell quality snr)
        for t=1:length(cellmeasures.rate_max)
            cellmeasures.response_snr{t}= (cellmeasures.rate_max{t}-cellmeasures.rate_spont{t}) /...
                cellmeasures.rate_spont{t};
        end
    end
    if isfield(cellmeasures,'rate') % compute selectivity index
        for t = 1:length(cellmeasures.rate)
            cellmeasures.selectivity_index{t} = ...
                (max(cellmeasures.rate{t})-min(cellmeasures.rate{t})) / ...
                max(cellmeasures.rate{t});
        end % t
    end
    if isfield(cellmeasures,'rate_peak') && isfield(cellmeasures,'rate_spont')
        % compute signal to noise ratio (don't confuse with cell quality snr)
        cellmeasures.response_snr= (cellmeasures.rate_peak-cellmeasures.rate_spont) /...
            cellmeasures.rate_spont;
    end
    if isfield(cellmeasures,'rate_late') && isfield(cellmeasures,'rate_early') && isfield(cellmeasures,'rate_spont')
        % compute Prolonged Discharge Index
        cellmeasures.pdi=thresholdlinear( ...
            (cellmeasures.rate_late-cellmeasures.rate_spont) /...
            (cellmeasures.rate_early-cellmeasures.rate_spont));
    end
    
    cellmeasures.index = cells(i).index;
    cellmeasures.type = cells(i).type;
    if isfield(cells,'wave')
        cellmeasures.wave = cells(i).wave;
        cellmeasures.std = cells(i).std;
        cellmeasures.snr = cells(i).snr;
    else
        cellmeasures.wave = [];
        cellmeasures.std = [];
        cellmeasures.snr = NaN;
    end
    cellmeasures.sample_interval = cells(i).sample_interval;
    if isfield(cells,'p_multiunit')
        cellmeasures.p_multiunit = cells(i).p_multiunit;
    end
    if isfield(cells,'p_subunit')
        cellmeasures.p_subunit = cells(i).p_subunit;
    end
    
    flds = fieldnames(cells);
    spike_flds = flds(strncmp('spike_',flds,6));
    for field = spike_flds
        if ~isempty(field) && isfield(cells(i),field{1})
            cellmeasures.(field{1}) = median( cells(i).(field{1}));
        end
    end
    
    if ~all(isnan(cellmeasures.wave)) || isempty(cellmeasures.wave)
        cellmeasures.contains_data = true;
    else
        cellmeasures.contains_data = false;
    end
    if ~cellmeasures.contains_data
        cellmeasures.usable = 0;
    end
    
    if isfield(record,'depth')
        cellmeasures.depth = record.depth-record.surface;
    else
        cellmeasures.depth = [];
    end
    
    if isfield(cells,'channel') % then check area
        cellmeasures.channel = cells(i).channel;
        if ~isempty(area)
            for a=1:length(area)
                if ismember(cellmeasures.channel,area(a).channels)
                    cellmeasures.area = area(a).name;
                    cellmeasures.relative_channel = cellmeasures.channel - min(area(a).channels) + 1;
                end
            end
        end
    end
    
    measures = [measures cellmeasures]; %#ok<AGROW>
end % cell i

if exist('fcm','file')
    cluster_spikes = true;
else
    cluster_spikes = false;
    logmsg('No fuzzy toolbox present for spike clustering');
end

if processparams.sort_compute_cluster_overlap &&  cluster_spikes
    % compute cluster overlap
    for c = channels2analyze % do this per channel
        ind = find([measures.channel]==c);
        n_cells = length(measures(ind));
        clust=zeros(n_cells);
        spike_features = cell(n_cells,1);
        for i=1:n_cells
            for field = spike_flds
                spike_features{i} = [ spike_features{i};cells(ind(i)).(field{1})'];
            end
        end
        max_spikes = 1000;
        cluster_features = [ 1 2 3 ]; % 5 ruins it
        for i=2:n_cells
            if isempty(spike_features{i})
                continue
            end
            n_spikesi = min(max_spikes,size(spike_features{i},2));
            for j=1:i-1
                if isempty(spike_features{j})
                    continue
                end
                n_spikesj = min(max_spikes,size(spike_features{j},2));
                features = [spike_features{i}(cluster_features,1:n_spikesi),spike_features{j}(cluster_features,1:n_spikesj)]';
                orglabel = [ones(1,n_spikesi),zeros(1,n_spikesj)];
                [dummy,Ulabel] =fcm(features,2,[2 50 1e-4 0]); %#ok<ASGLU>
                newlabel = double(Ulabel(1,:)>0.5);
                clust(i,j) = 2 * (sum(orglabel~=newlabel)/(n_spikesi+n_spikesj));
                if clust(i,j)>1
                    clust(i,j)=2-clust(i,j);
                end
            end
        end
        clust = clust + clust' + eye(length(clust));
        for i=1:n_cells
            measures(ind(i)).clust = clust(i,:); %#ok<AGROW>
        end
    end % channel c
end % if cluster_spikes
%end % reference r


% insert measures into record.measures
if (length(channels2analyze)==length(recorded_channels) && ...
        all( sort(channels2analyze)==sort(recorded_channels))) || ...
        ~isfield(measures,'channel') || ...
        ~isfield(record.measures,'channel')
    record.measures = measures;
else
    try
        record.measures(ismember([record.measures.channel],channels2analyze)) = []; % remove old
        record.measures = [record.measures measures];
        [dummy,ind] = sort([record.measures.index]); %#ok<ASGLU>
        record.measures = record.measures(ind);
    catch me % in case measures struct definition has changed
        switch me.identifier
            case 'MATLAB:catenate:structFieldBad'
                logmsg('Measures structure has changed since previous analysis. Removing previous results.');
            otherwise
                errormsg(me.message);
        end
        record.measures = measures;
    end
end

% extra analyses, e.g. ec_analyse_xos, ec_analyse_adaptation
if ~isempty(record.analysis)
    try
        record = feval(record.analysis,record);
    catch me
        errormsg(['Problem with analysis field in ' recordfilter(record) ...
            ': ' me.message]);
    end
end


measures = record.measures; 

% save measures file
if 0 && strncmp(record.stim_type,'background',10)==1
    measuresfile = fullfile(experimentpath(record),[record.datatype '_measures_OFF.mat']);
else
    measuresfile = fullfile(experimentpath(record),[record.datatype '_measures.mat']);
end

if allowchanges
    try
        save(measuresfile,'measures','-v7');
    catch me
        errormsg(['Could not write measures file ' measuresfile '. ' me.message]);
    end
end

% remove fields that take too much memory
record.measures = rmfields(record.measures,{});

record = add_distance2preferred_stimulus( record );
record.analysed = datestr(now);

return


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



