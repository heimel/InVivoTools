function puncta_db = generate_roidb(exper,dbname)
%generate_roidb
%
%  PUNCTA_DB = GENERATE_ROIDB(exper,DBNAME)
%     exper is dec number, like '10.24' or '11.21'
%     DBNAME is optional specific database name, e.g. 'colocalization'
%
%  To get info out of db structure try e.g.
%    intensities = shiftdim(reshape([puncta_db.intensity],8,2,length(puncta_db)),1)
%    lost = reshape([puncta_db.lost],8,length(puncta_db))'
%    gain = reshape([puncta_db.gain],8,length(puncta_db))'
%    present = reshape([puncta_db.present],8,length(puncta_db))'
%    figure;plot(sum(lost)./sum(present),'b');hold on;plot(sum(gain)./sum(present),'r')
%
%  Analyse by ANALYSE_PUNCTA_DB
%
% 2011-2013, Alexander Heimel
%

if nargin<1
    exper = [];
end
if isempty(exper)
    exper = experiment;
end
if nargin<2
    dbname = '';
end


% load stacks
debug = false;


switch debug
    case true
        disp('GENERATE_ROIDB: Temporarily usin alexander database for debugging');
        testdb = load_testdb('tptestdb_olympus_alexander');
    case false
        if isempty(dbname)
            switch exper
                case '10.24' % first gephyrin study
                    testdb = load_tptestdb_for_analysis;
                otherwise
                    testdbname = expdatabases( 'tp' );
                    [testdb,filename]=load_testdb(testdbname);
            end

        else
            testdb = load_testdb(['tptestdb_olympus_' dbname]);
        end
end

if isnumeric(exper)
    exper = num2str(exper);
end

testdb = testdb(find_record(testdb, ['experiment=' exper]));
disp('GENERATE_ROIDB: Loaded testdb.');

if isempty(testdb)
    disp('GENERATE_ROIDB: testdb is empty.');
    return
end

% get slices = days
slices = uniq(sort({testdb.slice}));
slices = slices(~cellfun(@isempty,slices));
days = cellfun(@(x) str2double(x(4:end)), slices,'UniformOutput',false);
[days, ind]=sort([days{:}]); %#ok<ASGLU>
slices = {slices{ind}};
n_slices = max(1,length(slices));

hbar = waitbar(0,'Extracting puncta from tptest databases' );

puncta_db = empty_puncta_record;
puncta_db = puncta_db([]);
for i = 1:length(testdb)
    waitbar( (i-1)/length(testdb),hbar);
    drawnow;
    
    record = testdb(i);
    tpsetup(record);
    params = tpreadconfig( record );
    if isempty(params)
        disp(['GENERATE_ROIDB: Empty image parameters. Skipping record ' num2str(i) '.']);
        continue
    end
    if ~isfield(params,'x_step') && ~isempty(params) %temporary to show which old tiffinfo should be removed
        disp(['GENERATE_ROIDB: For ' tpfilename(record) ' old tiffinfo should be removed.']);
    end
    
    if isempty(record.ROIs) || ~isfield(record.ROIs,'celllist')
        continue
    end
    rois = record.ROIs.celllist;
    ind = find_record( puncta_db,['mouse=' record.mouse ',stack=' record.stack ]);
    types = tpstacktypes(record);
    labels = tpstacklabels(record);
    if ~isempty(rois) && ~isfield(rois(1),'intensity_rel2dendrite')
        warning('GENERATE_ROIDB:NO_INTENSITY_REL2DENDRITE',...
            ['GENERATE_ROIDB: No intensity_rel2dendrite ' ...
            'for mouse= ' record.mouse ', stack=' record.stack ',slice=' record.slice ]);
    end
        
    % get abs values for absent puncta for channel 1
    spine = strcmp({rois.type},'spine');
    shaft = strcmp({rois.type},'shaft');
    synapse = spine | shaft;
    present = [rois.present];
    absent = ~present;
    
    if ~isempty(rois)
        i_mean = reshape([rois.intensity_mean],length(rois(1).intensity_mean),length(rois))';
    end
    if any(absent)
        % changed on 2012-02-18
        % channel_min = nanmean(i_mean(absent,:)  ); %min(i_mean);
        channel_min = prctile(i_mean(:,:),3  ); %min(i_mean);
    else
        disp('GENERATE_ROIDB: No absent puncta. Taking 90% of lowest intensity as minimum');
        channel_min = min(i_mean)*0.9;
    end
        
    if any(isnan(channel_min))
        disp('GENERATE_ROIDB: Channel_min is NaN');
    end
    
    channel_max = nanmean(i_mean(present&synapse,:)); %max(i_mean(synapse,:));
    if any(isnan(channel_max) )
        disp(['GENERATE_ROIDB: For ' shortrecord(record) ' Channel_max is NaN']);
    end
    if any(channel_min==channel_max)
        disp(['GENERATE_ROIDB: For ' shortrecord(record) ' Channel_max is channel_min']);
    end    
    
    for j = 1:length(rois)
        indp = find_record(puncta_db(ind),['index=' num2str(rois(j).index)]);
        if isempty(indp) % i.e. new punctum
            ind = [ind (length(puncta_db)+1)];
            indp = length(ind);
            punctum = empty_puncta_record;
            punctum.mouse = record.mouse;
            punctum.stack = record.stack;
            punctum.stack_hash = pm_hash('crc',[punctum.mouse ',' punctum.stack]);
            punctum.slice = 1:n_slices; % record.slice;
            punctum.index = rois(j).index;
            punctum.present = false(1,n_slices);
            punctum.neurite = NaN * ones(1,n_slices);
            punctum.intensity_green = NaN * ones(1,n_slices);
            punctum.intensity_red = NaN * ones(1,n_slices);
            punctum.type = NaN * ones(1,n_slices);
            punctum.labels = zeros(1,n_slices);
            punctum.distance = NaN *  ones(1,n_slices);
            punctum.density = NaN *  ones(1,n_slices);
            punctum.pixelshift = 0;
        else
            punctum = puncta_db(ind(indp));
        end
        if n_slices>1
            timepoint = strmatch(record.slice,slices);
        else
            timepoint = 1;
        end
        punctum.present(timepoint) = rois(j).present;
        punctum.neurite(timepoint) = rois(j).neurite(1);
        if length(rois(j).neurite)>1
            punctum.distance(timepoint) = rois(j).neurite(2);
        end
        if isfield(rois(j),'intensity_rel2dendrite')
            punctum.intensity_green(timepoint) = (rois(j).intensity_mean(1) - channel_min(1))/(channel_max(1)- channel_min(1)); %rel2synapse(1); %rel2dendrite(:);
            punctum.intensity_red(timepoint) = rois(j).intensity_rel2dendrite(2); %rel2dendrite(:);
        else
            punctum.intensity_green(timepoint) = NaN;
            punctum.intensity_red(timepoint) = NaN;
        end
        punctum.type(timepoint) = strmatch(rois(j).type,types);
        punctum.labels(timepoint) = 0;
        for k = 1:length(rois(j).labels)
            % labels becomes binary convert of roi.labels
            label_nr = strmatch(rois(j).labels{k},labels);
            if ~isempty(label_nr)
                punctum.labels(timepoint) = punctum.labels(timepoint) + 2^(label_nr-1);
            end
            
        end
        punctum.pixelshift = ~isempty(findstr(record.comment,'pixelshift'));
        
        if is_linearroi(rois(j).type)
            if ~isempty(params)
                punctum.neurite(timepoint) = punctum.index;
                if length(rois(j).zi)==1  % zi used to be only 1 number
                    rois(j).zi = ones(size(rois(j).xi))*rois(j).zi;
                end
                
                punctum.distance(timepoint) = sum(sqrt( ...
                    (params.x_step*diff(rois(j).xi)).^2 + ...
                    (params.y_step*diff(rois(j).yi)).^2 + ...
                    (params.z_step*diff(rois(j).zi)).^2 ));
            end
        end
        
        
        puncta_db(ind(indp)) = punctum;
        
    end
end
close(hbar);

disp('generate_roidb: parsing puncta data');
for i = 1:length(puncta_db)
    punctum = puncta_db(i);
    if nanstd(punctum.neurite)~=0
        disp(['GENERATE_ROIDB: Punctum mouse=' punctum.mouse ...
            ',stack=' punctum.stack ',index=' num2str(punctum.index) ...
            ' has been assigned to neurites: ' num2str(punctum.neurite)]);
    end
    punctum.neurite = nanmedian(punctum.neurite);
    
    
    punctum.neurite_hash = pm_hash('crc',[punctum.mouse ',' punctum.stack ',' num2str(punctum.neurite)]);
    punctum.gained(1) = false;
    punctum.gained(2:n_slices) = ~punctum.present(1:end-1) & punctum.present(2:end);
    punctum.lost(1) = false;
    punctum.lost(2:n_slices) = punctum.present(1:end-1) & ~punctum.present(2:end);
    punctum.tobelost(1:n_slices-1) = punctum.present(1:end-1) & ~punctum.present(2:end);
    punctum.tobelost(n_slices) = 0;
    punctum.tobegained(1:n_slices-1) = ~punctum.present(1:end-1) & punctum.present(2:end);
    punctum.tobegained(n_slices) = 0;
    
    for j=1:n_slices
        if punctum.present(j)
            until =            find(punctum.present(j:end)==0,1)+(j-1);
            if isempty(until)
                until = n_slices;
            end
            punctum.persisting_from_day_until(j) = until; % will be translated to true?
        else
            punctum.persisting_from_day_until(j) = false;
        end
    end
    puncta_db(i) = punctum;
end


disp('GENERATE_ROIDB: Calculating neurite densities.');
ind_neurites = find_record(puncta_db,['type=' num2str(strmatch('dendrite',tpstacktypes))]);
for i=1:length(ind_neurites)
    dendrite = puncta_db(ind_neurites(i));
   ind = find_record(puncta_db,['stack_hash='  num2str(dendrite.stack_hash) ',neurite=' num2str(dendrite.index)]);
   puncta_db(ind_neurites(i)).density = (length(ind)-1) / dendrite.distance;
end

db = puncta_db;


filename = fullfile( expdatabasepath,exper,expdatabases('roi'));
if ~isempty(dbname)
    filename = [filename '_' dbname];
elseif ~isempty(exper)
    filename = [filename '_' exper];
end
filename = [filename '.mat'];
save( filename,'db');
   
disp(['GENERATE_ROIDB: Saved puncta_db as ' filename ]);


function punctum = empty_puncta_record
punctum.mouse = '';
punctum.stack = '';
punctum.stack_hash = []; % encodes mouse and stack
punctum.slice = [];%'';
punctum.datatype = 'roi';
punctum.index = [];
punctum.present = logical([]);
punctum.neurite = [];
punctum.neurite_hash = []; % encodes mouse, stack and dendrite
punctum.intensity_green = [];
punctum.intensity_red = [];
punctum.type = [];
punctum.gained = logical([]);
punctum.tobegained = logical([]);
punctum.lost = logical([]);
punctum.tobelost = logical([]);
punctum.labels = []; % binary
punctum.distance = []; % distance to neurite, or neurite length
punctum.persisting_from_day_until = logical([]); %nan(1,8);
punctum.density = []; % for each dendrite number of puncta per um
punctum.pixelshift = [];

function shrtrec = shortrecord( record )
shrtrec = ['mouse=' record.mouse ',date=' record.date ',stack=' record.stack];
