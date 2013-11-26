function record=analyse_ectestrecord(record,verbose)
%ANALYSE_ECTESTRECORD
%
%   RECORD=ANALYSE_ECTESTRECORD( RECORD)
%
% 2007-2013, Alexander Heimel

if nargin<2
    verbose = [];
end

if isempty(verbose)
    verbose = true;
end

if strcmp(record.datatype,'ec')~=1
    warning('InVivoTools:datatypeNotImplemented',['datatype ' record.datatype ' is not implemented.']);
    return
end

if isempty(record.monitorpos)
    msg =['Monitor position is missing in record. mouse=' record.mouse ',date=' record.date ',test=' record.test];
    disp(['ANALYSE_ECTESTRECORD: ' msg]);
    errordlg(msg,'Analyse ectestrecord');
end

datapath=ecdatapath(record);
if ~exist(datapath,'dir')
    errordlg(['Folder ' datapath ' does not exist.']);
    disp(['ANALYSE_ECTESTRECORD: Folder ' datapath ' does not exist.'])
    return
end

% per date one cksdirstruct to conform to Nelsonlab practice
cksds=cksdirstruct(datapath);

processparams = ecprocessparams(record);

WaveTime_Spikes = struct([]);

switch lower(record.setup)
    case 'antigua'
        Tankname = 'Mouse';
        blocknames = [record.test];
        clear EVENT
        EVENT.Mytank = datapath;
        EVENT.Myblock = blocknames;
        EVENT = importtdt(EVENT);
        Dells=EVENT.snips.Snip.times;
        EVENT.Myevent = 'Snip';
        EVENT.type = 'snips';
        %         EVENT.Triallngth =
        %         EVENT.timerange(2)-EVENT.strons.tril(1)+(1/EVENT.snips.Snip.sampf);
        %         EVENT.Start = +(1/EVENT.snips.Snip.sampf);
        EVENT.Start = 0;
        read_chan1=[2 7 8 9 10];
        disp(['ANALYSE_ECTEST: FOR ONLY CHANNEL # ',num2str(read_chan1)]);

        total_length=EVENT.timerange(2)-EVENT.strons.tril(1);
        WaveTime_Fpikes=struct([]);
        for i=1:length(read_chan1)
        WaveTime_fpikes.time=[];
        WaveTime_fpikes.data=[];
        
        for kk=1:ceil(total_length/60)
           % clear WaveTime_chspikes
            EVENT.Triallngth = min(60,total_length-60*(kk-1));
            WaveTime_chspikes = ExsnipTDT(EVENT,EVENT.strons.tril(1)+60*(kk-1));
            WaveTime_fpikes.time=[WaveTime_fpikes.time;WaveTime_chspikes(read_chan1(i),1).time];
            WaveTime_fpikes.data=[WaveTime_fpikes.data;WaveTime_chspikes(read_chan1(i),1).data];
        end
        
        WaveTime_Fpikes=[WaveTime_Fpikes;WaveTime_fpikes];
        end
        % always only ONE channel (at this time)

%         WaveTime_Fpikes = ExsnipTDT(EVENT,EVENT.strons.tril(1));
%         read_chan1=[6]; % always only ONE channel (at this time)

        numchannel1 =length(read_chan1);
        numchannel=0;
        %         Fells={};
        %         WaveTime_Spikes=struct([]);
        for ii=1:numchannel1
            clear kll
            clear spikes
            kll.sample_interval = 1/EVENT.snips.Snip.sampf;
            kll.data = WaveTime_Fpikes(ii,1).time;
            spikes=WaveTime_Fpikes(ii,1).data;
            kll = get_spike_features(spikes, kll );
            [wtime_sp,nchan] = spike_sort_wpca(spikes,kll);
            WaveTime_Spikes=[WaveTime_Spikes;wtime_sp];
            numchannel=numchannel+nchan;
            ii
            %             Fells=[Fells;Dells{read_chan1(ii),1}];
            %             WaveTime_Spikes=[WaveTime_Spikes;WaveTime_Fpikes(read_chan1(ii),1)];
        end
        
        read_chan=1:numchannel;
        
        %         if isempty(Cells)
        %             return
        %         end
        
        if isempty(WaveTime_Fpikes)
            return
        end
        
        %     EVENT.Start =  0;
        %     EVENT.Triallngth =  EVENT.timerange(2);
        %     SPIKES=ExsnipTDT(EVENT);
        
        % load stimulus starttime
        smrfilename=fullfile(EVENT.Mytank,EVENT.Myblock);
        
        %         stimsfilename=fullfile(smrfilename,'stims.mat');
        %         stimsfile=load(stimsfilename);
        [stimsfile,stimsfilename] = getstimsfile( record );
        EVENT.strons.tril = EVENT.strons.tril * processparams.secondsmultiplier;
        
        %         ssts = getstimscripttimestruct(cksds,EVENT.Myblock);
        %
        desc_long=[smrfilename ':' stimsfilename];
        desc_brief=EVENT.Myblock;
        detector_params=[];
        
        intervals=[stimsfile.start ...
            stimsfile.MTI2{end}.frameTimes(end)+10];
        %
        % % shift time to fit with TTL and stimulustimes
        timeshift=stimsfile.start-EVENT.strons.tril(1);
        % % disp('IMPORTSPIKE2: Taking first TTL for time synchronization');
        %
        timeshift=timeshift+ processparams.trial_ttl_delay; % added on 24-1-2007 to account for delay in ttl
        %
        %  cells={};
        cells=struct([]);
        
        
        % load acquisitionfile for electrode name
        % to get samplerate acqParams_out should be used instead of _in
        ff=fullfile(getpathname(cksds),record.test,'acqParams_in');
        f=fopen(ff,'r');
        if f==-1
            disp(['Error: could not open ' ff ]);
            return;
        end
        fclose(f);  % just to get proper error
        acqinfo=loadStructArray(ff);
        
        ffout=[ff(1:end-2) 'out'];
        if exist(ffout,'file')~=2
            copyfile(ff,ffout,'f');
        end
        
        
        [px,expf] = getexperimentfile(cksds,1);
        
        %         cellnamedel=sprintf('cell_%s_%s_%.4d*',acqinfo(1).name,'irrelevant',acqinfo(1).ref);
        deleteexpvar(cksds,'cell*'); % delete all old representations
        
        cl = 1;
        for ch = 1:numchannel
            % cellname needs to start with 'cell' to be recognized
            % by cksds
            %             if isempty(Cells{ch})
            %                 continue
            %             end
            if isempty(WaveTime_Spikes(ch,1))
                continue
            end
            clear('cll');
            %             cll.name=sprintf('cell_%s_%s_%.4d_%.3d',...
            %                 num2str(cl));
            
            unitchannelname = 'snips' ;
            cll.name=sprintf('cell_%s_%s_%.4d_%.3d',...
                acqinfo(1).name,unitchannelname,acqinfo(1).ref,read_chan(ch));
            
            
            cll.intervals = intervals;
            cll.sample_interval = 1/EVENT.snips.Snip.sampf;
            cll.desc_long = desc_long;
            cll.desc_brief = desc_brief;
            cll.index = read_chan(ch); % will be used to identify cell
            %             cll.data = WaveTime_Spikes(ch,1).time * processparams.secondsmultiplier + timeshift;
            cll.data = WaveTime_Spikes(ch,1).time * processparams.secondsmultiplier + timeshift;
            cll.detector_params=detector_params;
            cll.trial=EVENT.Myblock;
            spikes=WaveTime_Spikes(ch,1).data;
            %             spikes=zeros(20,size(WaveTime_Spikes(chan,1).data,1));
            %             for i=1:length(WaveTime_Spikes(chan,1).data)
            %                 A=wavelet_decompose(WaveTime_Spikes(chan,1).data(i,:),3,'db4');
            %                 spikes(:,i)=A(1:20,3);
            %             end;
            %             spikes=spikes';
            cll.wave = mean(spikes,1);
            cll.std = std(spikes,1);
            cll.snr = (max(cll.wave)-min(cll.wave))/mean(cll.std);
            cll = get_spike_features(spikes, cll );
            %   cells(1,cl) = cll;
            %   spikes = double(data_units.adc(ind,:))/10; % to get mV     me: why 10?
            
            cells = [cells,cll];
            cl = cl+1;
        end
        
        % transfer cells into experiment file of cksds object
        cksds = cksdirstruct(EVENT.Mytank);
        
        %        cellnamedel=sprintf('cell_%s_%s_%.4d_*',acqinfo(1).name,unitchannelname,acqinfo(1).ref);
        %cellnamedel=sprintf('cell_%s_%s_%.4d_*',acqinfo(1).name,'irrelevant',acqinfo(1).ref);
        %cellnamedel = '*'
        deleteexpvar(cksds,'cell*'); % delete all old representations
        
        for cl=1:length(cells)
            acell=cells(cl);
            thecell=cksmultipleunit(acell.intervals,acell.desc_long,...
                acell.desc_brief,acell.data,acell.detector_params);
            saveexpvar(cksds,thecell,acell.name,1);
        end
        
        %
        % nr = getallnamerefs(cksds);
        %     g = getcells(cksds,nr(1))
        
    otherwise
        % import spike2 data into experiment file
        cells = importspike2([record.test filesep 'data.smr'],record.test,getpathname(cksds),'Spikes','TTL');     
        read_chan1=[1];
end


if isempty(cells)
    return
end

if processparams.sort_with_klustakwik
    cells = sort_with_klustakwik(cells,record);
elseif processparams.compare_with_klustakwik
    kkcells = sort_with_klustakwik(cells,record);
    if ~isempty(kkcells)
        cells = importspike2([record.test filesep 'data.smr'],record.test,getpathname(cksds),'Spikes','TTL');
        cells = compare_spike_sortings( cells, kkcells);
    end
end

% switch lower(record.setup)
%     case 'antigua'
%         % dont compute spike intervals
%         isi = [];
%     otherwise
        isi = get_spike_interval( cells );
% end

% save all spikes
spikesfile = fullfile(ecdatapath(record),record.test,'_spikes.mat');

save(spikesfile,'cells','isi');

ssts = getstimscripttimestruct(cksds,record.test);

if isfield(record,'stimscript') && isempty(record.stimscript)
    % fill in stimscript class
    stims = getstimsfile(record);
    if isempty(stims)
        return
    end
    record.stimscript = class(stims.saveScript(1));
end

measures=[];

nr = getallnamerefs(cksds);
for r=1:length(nr) % for all refs
    g = getcells(cksds,nr(r));
    if isempty(g)
        continue
    end
    %     switch lower(record.setup) % Mehran
    %         case 'antigua'
    %             fg=g;
    %             g={};
    %             for j=1:numchannel
    %                 g=[g;fg{read_chan(j),1}];
    %             end
    %     end
    % load cells from experimentfile
    loadstr = ['''' g{1} ''''];
    for i=2:length(g)
        loadstr = [loadstr ',''' g{i} ''''];
    end;
    eval(['d = load(getexperimentfile(cksds),' loadstr ',''-mat'');']);
    
    if length(g)>10 % dont show more than 10 cells in the analysis
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
        %         switch lower(record.setup) % Mehran
        %             case 'antigua'
        %                 inp.spikes=cells(1,i).data;
        %             otherwise
        inp.spikes=d.(g{i});
        %         end
        
        n_spikes=0;
        %         switch lower(record.setup) % Mehran
        %             case 'antigua'
        %                 for k=1:length(ssts.mti)
        %                     try
        %                         n_spikes=n_spikes+length(get_dataTDT(inp.spikes,...
        %                             [ssts.mti{k}.startStopTimes(1),...
        %                             ssts.mti{k}.startStopTimes(end)]));
        %                     catch
        %                         n_spikes=n_spikes+length(get_dataTDT(inp.spikes,...
        %                             [ssts.mti{k}.startStopTimes(1),...
        %                             ssts.mti{k}.startStopTimes(end-1)]));
        %                     end
        %                 end
        %                 inp.spikes={inp.spikes};
        %             otherwise
        for k=1:length(ssts.mti)
            try
                n_spikes=n_spikes+length(get_data(inp.spikes,...
                    [ssts.mti{k}.startStopTimes(1),...
                    ssts.mti{k}.startStopTimes(end)]));
            catch
                n_spikes=n_spikes+length(get_data(inp.spikes,...
                    [ssts.mti{k}.startStopTimes(1),...
                    ssts.mti{k}.startStopTimes(end-1)]));
            end
        end
        %         end
        inp.cellnames{1} = [g{i}];
        inp.title=[g{i}]; % only used in period_curve
        disp(['ANALYSE_ECTESTRECORD: Cell ' num2str(i) ' of ' num2str( length(g) ) ...
            ', ' g{i} ', ' num2str(n_spikes) ' spikes']);
        
        %         if n_spikes == 0
        %             cellmeasures.contains_data = false;
        %             cellmeasures.usable = false;
        %             measures = [measures cellmeasures];
        %             continue
        %         end
        
        stim_type = record.stim_type;
        try
            stim = get(inp.st.stimscript);
            if ~isempty(stim)
                switch class(stim{1})
                    case 'stochasticgridstim'
                        stim_type = 'sg';
                end
            end
        end
        
        
        switch stim_type
            case {'sg','sg_adaptation'}
                cellmeasures = analyse_sg(inp,n_spikes,record);
            case {'hupe','border','lammemotion','lammetexture'}
                cellmeasures = analyse_ectest_by_typenumber(inp,record);
            otherwise
                cellmeasures = analyse_ps(inp,record,verbose);
        end
        
        
        cellmeasures.usable = 1;
        %          try
        %              if cellmeasures.rate_early<cellmeasures.rate_spont
        %                  disp('spont rate higher than early response rate')
        %                  cellmeasures.usable=0;
        %              end
        %          end
        
        %         try
        %             if cellmeasures.time_onset<0.005
        %                 disp('onset time is too early');
        %                 cellmeasures.usable=0;
        %             end
        %         end
        
        if ~isempty(find_record(record,['comment=*' num2str(i) ':axon*']))
            cellmeasures.usable=0;
        end
        
        if ~isempty(find_record(record,['comment=*' num2str(i) ':bad*']))
            cellmeasures.usable=0;
        end
        
        if isempty(measures) % may not be correct! check importspike2
            cellmeasures.type='mu';
        else
            cellmeasures.type='su';
        end
        
        try
            % compute Reponse Index
            cellmeasures.ri= (cellmeasures.rate_peak-cellmeasures.rate_spont) /...
                cellmeasures.rate_peak;
        end
        
        try
            % compute signal to noise ratio (don't confuse with cell quality snr)
            cellmeasures.response_snr= (cellmeasures.rate_peak-cellmeasures.rate_spont) /...
                cellmeasures.rate_spont;
        end
        
        try
            % compute Prolonged Discharge Index
            cellmeasures.pdi=thresholdlinear( ...
                (cellmeasures.rate_late-cellmeasures.rate_spont) /...
                (cellmeasures.rate_early-cellmeasures.rate_spont));
        end
        
        cellmeasures.index = cells(i).index;
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
        
        flds = fields(cells);
        spike_flds = {flds{strmatch('spike_',flds)}};
        for field = spike_flds
            cellmeasures.(field{1}) = median( cells(i).(field{1}));
        end
        
        if ~all(isnan(cellmeasures.wave)) || isempty(cellmeasures.wave)
            cellmeasures.contains_data = true;
        else
            cellmeasures.contains_data = false;
        end
        if ~cellmeasures.contains_data
            cellmeasures.usable = 0;
        end
        
        cellmeasures.depth = record.depth-record.surface;
        
        measures = [measures cellmeasures];
    end % cell i
    
    if exist('fcm','file')
        cluster_spikes = true;
    else
        cluster_spikes = false;
        disp('ANALYSE_ECTESTRECORD: No fuzzy toolbox present for spike clustering');
    end
    
    % compute cluster overlap
    n_cells = length(measures);
    if cluster_spikes
        clust=zeros(n_cells);
        
        for i=1:n_cells
            spike_features{i} = [];
            for field = spike_flds
                spike_features{i} = [ spike_features{i};cells(i).(field{1})'];
            end
        end
        
        max_spikes = 200;
        cluster_features = [ 1 2 3 4 ]; % 5 ruins it
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
                %  [~,ind] = sort(rand(n_spikesi+n_spikesj,1));
                %  orglabel = orglabel(ind);
                %  features = features(ind,:);
                
                [dummy,Ulabel] =fcm(features,2,[2 50 1e-4 0]); %#ok<ASGLU>
                
                newlabel = double(Ulabel(1,:)>0.5);
                
                
                clust(i,j) = 2 * (sum(orglabel~=newlabel)/(n_spikesi+n_spikesj));
                if clust(i,j)>1
                    clust(i,j)=2-clust(i,j);
                end
                
                %                 ACC = [(sum(abs(double(Ulabel(1,:)>0.5)-orglabel(1,:))))/size(fl1,2),...
                %                     (sum(abs(double(Ulabel(1,:)>0.5)-orglabel(2,:))))/size(fl1,2)];
                %                 ACC = [(sum(abs(newlabel-orglabel(1,:))))/size(orglabel,2),...
                %                     (sum(abs(newlabel-orglabel(2,:))))/size(orglabel,2)];
                %                 clust(i,j) = min(ACC); % overlap
            end
        end
        clust = clust + clust' + eye(length(clust));
        for i=1:n_cells
            measures(i).clust = clust(i,:);
        end
    end % if cluster_spikes
end % reference r


measuresfile = fullfile(ecdatapath(record),record.test,['_measures',num2str(read_chan1),'.mat']);
save(measuresfile,'measures','WaveTime_Spikes');

record.analysed = datestr(now);
record.measures = measures;

record = add_distance2preferred_stimulus( record );

return

