function result = tppuncta_analysis( puncta_type, mouse_type )
%TPPUNCTA_ANALYSIS
%
%  RESULT = TPPUNCTA_ANALYSIS( PUNCTA_TYPE, MOUSE_TYPE )
%      PUNCTA_TYPE can be 'shaft','spine','synapse','all'
%       'synapse' takes both 'shaft' and 'spine' and is the default option
%       'all' should usually not be taken as it also includes aggregrates 
%       and unknowns
%
%      MOUSE_TYPE filters mouse from mouse_db with type=MOUSE_TYPE
%        e.g. 'control adult' or 'MD 12d adult'
%
%  Use TPPUNCTA_RESULTS( RESULT ) to visualize results.
%
% 2011, Alexander Heimel
%
if nargin<1, puncta_type = ''; end
if isempty(puncta_type), puncta_type = 'synapse'; end
if nargin<2, mouse_type = ''; end
if isempty(mouse_type)
    %mouse_type = 'control adult';
    %mouse_type = '*';
    mouse_type = 'MD 12d adult';
end
experiment = '10.24';
n_channels = 2;
channels = (1:n_channels);


parameters.big = 0.66; % percentile to consider puncta big (i.e. 0.2 is top 80%)
parameters.minimum_puncta_per_dendrite = 8;

using_unassigned_puncta=false;


disp('CHECK PUNCTA SWITCHING BETWEEN SPINE, SHAFT, AGGREGATE, UNKNOWN');
disp('WHEN IMPORTING RELOAD INTENSITIES');
disp('WHEN MANUAL ASSIGNING DENDRITE, SET DISTANCE');
disp('CHECK AT DISAPPEARING SPINE PUNCTA IF SPINE IS STILL THERE');
disp('IMPROVE MATCHING JUMPING TIME POINTS');


% load mice
db=[];
load(fullfile( expdatabasepath, 'mousedb.mat'),'-mat');
mousedb = db;
mousedb = mousedb(find_record(mousedb,['mouse=' experiment '*,type=' mouse_type]));
disp(['TPPUNCTA_ANALYSIS: selected ' num2str(length(mousedb)) ' mice for type ' mouse_type ]);

% load stacks
debug = false;
switch debug
    case true
        disp('TPPUNCTA_ANALYSIS: temporarily usin alexander database for debugging');
        testdb = load_testdb('tptestdb_olympus_alexander');
        testdb = testdb(find_record(testdb, ...
            ['(mouse=10.24.1.25,stack=tuft1)|'...
            '(mouse=10.24.1.25,stack=tuft2)|' ...
            '(mouse=10.24.1.25,stack=tuft3)' ] ));
    case false
        testdb = load_tptestdb_for_analysis;
end
testdb = testdb(find_record(testdb, ['experiment=' experiment]));

% select tests from selected mice
db = [];
for i=1:length(mousedb)
    db = [db testdb(find_record(testdb,['mouse=' mousedb(i).mouse]))];
end



result.puncta_type = puncta_type;


disp(['TPPUNCTA_ANALYSIS: selected ' num2str(length(db)) ' records.' ]);


% get all stacks
stacks = {};
for i = 1:length(db)
    stacks{i} = [db(i).mouse ':' db(i).stack]; %#ok<AGROW>
end
stacks = uniq(sort(stacks));
n_stacks = length( stacks );

% get slices = days
slices = uniq(sort({db.slice}));
days = cellfun(@(x) str2double(x(4:end)), slices,'UniformOutput',false);
[days, ind]=sort([days{:}]);
slices = {slices{ind}};
n_slices = length(slices);

% get all dendrites
dendrites = {};
for s = 1:n_stacks
    mouse = stacks{s}(1:find(stacks{s}==':')-1);
    stack = stacks{s}(find(stacks{s}==':')+1 : end);
    
    
    ind = find_record(db , ['mouse=' mouse ',stack=' stack]);
    
    if using_unassigned_puncta
        dendrites{end+1} = [stacks{s} ':' 'nan' ]; %#ok<AGROW> % for rois unassigned to dendrites
    end
    
    for i = ind
        if isfield(db(i),'ROIs') && isfield(db(i).ROIs,'celllist') && ~isempty(db(i).ROIs.celllist)
            % get all dendrites for this stack
            ind_dendrite = find( logical(strcmp({db(i).ROIs.celllist(:).type}, 'dendrite')) );
            for j = ind_dendrite
                dendrites{end+1} = [stacks{s} ':' num2str(db(i).ROIs.celllist(j).index) ]; %#ok<AGROW>
            end
        end
    end % record i
end % stack s
dendrites = uniq(sort(dendrites))';
n_dendrites = length(dendrites);







% start gathering puncta info
dendritic_length = NaN * ones(n_dendrites, n_slices);
puncta_density = NaN * ones(n_dendrites, n_slices);
puncta = cell(n_dendrites,1);
puncta_per_stack = cell(n_stacks,1);
puncta_ranking = cell(n_stacks,1);
puncta_intensities = cell(n_dendrites,2);
puncta_r = cell(n_dendrites,1);
reversed_dendrite = NaN * ones(n_dendrites, 1);

puncta_ranking_motility = NaN * ones(n_dendrites, n_slices-1);

for d = 1:n_dendrites
    mouse = dendrites{d}(1:find(dendrites{d}==':',1)-1);
    stack = dendrites{d}(find(dendrites{d}==':',1)+1 : find(dendrites{d}==':',1,'last')-1);
    stack_nr = strmatch([mouse ':' stack],stacks);
    
    dendrite = str2num(dendrites{d}(find(dendrites{d}==':',1,'last')+1 : end)); %#ok<ST2NM>
    
    
    [~,reversed_dendrite(d) ] = ...
        blinding_tpdata( struct('mouse',mouse,'stack',stack),1);
    
    ind = find_record(db , ['mouse=' mouse ',stack=' stack]);
    max_index = 0;
    for i = ind
        if isfield(db(i),'ROIs') && isfield(db(i).ROIs,'celllist') && ~isempty(db(i).ROIs.celllist)
            max_index = max([max_index db(i).ROIs.celllist( strcmp({db(i).ROIs.celllist.type},'spine') | strcmp({db(i).ROIs.celllist.type},'shaft') ).index]);
        end
    end
    puncta{d} = nan*zeros(max_index,n_slices);
    puncta_r{d} = nan*zeros(max_index,n_slices,3);
    puncta_per_stack{stack_nr}(1:max_index,1:n_slices) = 0;
    puncta_per_stack_rank{stack_nr}(1:max_index,1:n_slices) = NaN;
end



for d = 1:n_dendrites
    mouse = dendrites{d}(1:find(dendrites{d}==':',1)-1);
    stack = dendrites{d}(find(dendrites{d}==':',1)+1 : find(dendrites{d}==':',1,'last')-1);
    stack_nr = strmatch([mouse ':' stack],stacks);
    
    dendrite = str2num(dendrites{d}(find(dendrites{d}==':',1,'last')+1 : end)); %#ok<ST2NM>
    
    
    for slice = 1:n_slices
        
        ind = find_record(db , ['mouse=' mouse ',stack=' stack ',slice=' slices{slice}]);
        if length(ind)>1
            error(['More than one slice for mouse=' mouse ', stack=' stack ', slice=' slices{slice} ]);
        end
        if isempty(ind)
            continue
        end
        
        puncta{d}(:,slice) = 0;
        
        if  ~isfield(db(ind),'ROIs') || ~isfield(db(ind).ROIs,'celllist') || isempty(db(ind).ROIs.celllist)
            continue
        end
        
        celllist = db(ind).ROIs.celllist;
        
        dendrite_vector = celllist( [celllist(:).index]==dendrite );
        if isfield(celllist,'neurite')
            % get rois on specific dendrites
            
            % temp function to solve problem with missing distance in neurite field
            warning('TPPUNCTA_ANALYSIS:FIX_DISTANCE','TPPUNCTA_ANALYSIS: temporary fix for missing distance');
            warning('OFF','TPPUNCTA_ANALYSIS:FIX_DISTANCE');
            ln = cellfun(@length,{celllist.neurite});
            for i=find(ln==1)
                celllist(i).neurite(2) = NaN;
            end
            
            links = reshape([celllist(:).neurite],2,length(celllist))';
            if isnan(dendrite)
                on_this_dendrite_ind = ( isnan(links(:,1)) );
                if sum(on_this_dendrite_ind)>20
                    
                    disp(['TPPUNCTA_ANALYSIS: ' num2str(sum(on_this_dendrite_ind)) ...
                        ' puncta not on dendrite: mouse=' mouse ...
                        ', stack=' stack ', slice=' slices{slice} ]);
                else
                    temp_ind = find(on_this_dendrite_ind);
                    for i=temp_ind(:)'
                        if ~strcmp(celllist(i).type,'dendrite') && ~strcmp(celllist(i).type,'glia')
                            disp(['TPPUNCTA_ANALYSIS: punctum ' ...
                                num2str(celllist(i).index) ' not on dendrite: mouse='...
                                mouse ', stack=' stack ', slice=' slices{slice} ]);
                        end
                    end
                    
                end
                on_this_dendrite_ind = [];
                
            else
                % select only from this dendrite
                on_this_dendrite_ind = ( links(:,1) == dendrite);
            end
            celllist = celllist( on_this_dendrite_ind );
        else
            if ~isnan(dendrite)
                celllist = celllist([] );
            end
        end
        
        
        % get puncta locations
        if ~isempty(celllist)
            puncta_r{d}([celllist.index],slice,1) = cellfun(@nanmean,{celllist(:).xi});
            puncta_r{d}([celllist.index],slice,2) = cellfun(@nanmean,{celllist(:).yi});
            puncta_r{d}([celllist.index],slice,3) = cellfun(@nanmean,{celllist(:).zi});
        end
        
        shaft_ind = logical(strcmp({celllist(:).type},'shaft'));
        spine_ind = logical(strcmp({celllist(:).type},'spine'));
        switch result.puncta_type
            case 'all' 
                warning('TPPUNCTA_ANALYSIS:ALL',...
                    ['TPPUNCTA_ANALYSIS: taking all puncta. '...
                    'Only to be used for data cleaning. Consider using ''synapse'',''spine'' or ''shaft''']);
                warning('OFF','TPPUNCTA_ANALYSIS:ALL');
            case 'synapse'
                celllist = celllist(shaft_ind | spine_ind);
            case 'spine'
                celllist = celllist( spine_ind);
            case 'shaft'
                celllist = celllist( shaft_ind);
        end
        
        if ~isfield(celllist,'present')
            for i = 1:length(celllist)
                celllist(i).present = 1;
            end
        end
        
        % set ROI intensities
        
        % first fix when ROI intensities are not length 2
        ln = cellfun(@length,{celllist.intensity_mean});
        for i=find(ln==1)
            celllist(i).intensity_mean(2) = NaN;
        end

        %intensities = reshape([celllist.intensity_mean],2,length(celllist))';
        intensities = reshape([celllist.intensity_rel2dendrite],2,length(celllist))';
        for ch = channels
            puncta_intensities{d,ch}([celllist.index],slice) = intensities(:,ch);
            puncta_per_stack_intensities{stack_nr,ch}([celllist.index],slice) = intensities(:,ch);
        end
        
        % select present
        present = [celllist(:).present];
        celllist = celllist(logical(present));
        
        % set puncta presence
        puncta{d}([celllist.index],slice) = 1;

        
        % calculate dendrite length and puncta density
        if ~isempty(dendrite_vector)
            if ~exist(tpfilename(db(ind)),'file')
                disp(['TPPUNCTA_ANALYSIS: no image data for ' ...
                    tpfilename(db(ind)) ...
                    ' to calculate dendrite length.']);
            else
                params = tpreadconfig(db(ind));
                if ~isfield(params,'x_step') %temporary to show which old tiffinfo should be removed
                    tpfilename(db(ind))
                end
                dendritic_length( d,slice ) = sum(sqrt( ...
                    (params.x_step*diff(dendrite_vector.xi)).^2 + ...
                    (params.y_step*diff(dendrite_vector.yi)).^2 + ...
                    (params.z_step*diff(dendrite_vector.zi)).^2 ));
                
                puncta_density( d,slice ) = length(celllist) / dendritic_length( d,slice );
            end
        end

        % assign puncta per stack
        puncta_per_stack{stack_nr}([celllist(:).index],slice) = d;
        if ~isempty(celllist)
            puncta_per_stack_type{stack_nr}([celllist(:).index],slice) = {celllist.type};
        end
        
        % calculate puncta rank
        if ~isempty(celllist)
            puncta_per_stack_rank{stack_nr}([celllist.index],slice) = ...
                ranks(puncta_intensities{d,1}([celllist.index],slice)) / length(celllist);
        end
        
        
    end % slices slice
    %puncta{d}(puncta{d}==0) = NaN;
    
end % dendrite d

dendrites
for s=1:length(puncta_per_stack)
    %puncta_per_stack{s}(puncta_per_stack{s}==0) = NaN;
    puncta_per_stack_rank{s}(puncta_per_stack_rank{s}==0) = NaN;
    puncta_per_stack_present{s} = (puncta_per_stack{s}>0);
    
    
    %    puncta_ranking_motility(d,:) = mean(abs(diff(puncta_ranking{d}')'));
    
    % puncta switching dendrite:
    switches = (abs(puncta_per_stack{s}-repmat(nanmedian(puncta_per_stack{s},2),1,8))>0);
    switching_puncta = find(any(switches,2));
    if 0 && any(switches(:))
        
        disp(['TPPUNCTA_ANALYSIS: ' stacks{s} ': ' num2str(sum(switches)) ' puncta switching dendrite assignment']);
        % remove switching puncta
        disp('TPPUNCTA_ANALYSIS: removing switching puncta');
        temp=puncta_per_stack{s}(switching_puncta,:);
        temp(:,end+1) = switching_puncta;
        stacks{s}
        temp
        puncta_per_stack{s}(switching_puncta,:) = nan;
        for d = 1:n_dendrites
            stack = dendrites{d}(1 : find(dendrites{d}==':',1,'last')-1);
            if strcmp(stack,stacks{s})
                puncta{d}(switching_puncta,:) = 0;
                puncta_r{d}(switching_puncta,:,:) = 0;
            end
        end
    end
    
    % assign shaft or spine type
    puncta_per_stack_is_shaft = strcmp(puncta_per_stack_type{s},'shaft');
    puncta_per_stack_is_spine = strcmp(puncta_per_stack_type{s},'spine');
    
end





% assign result structure
result.puncta = puncta;
result.puncta_r = puncta_r;
result.dendrites = dendrites;
result.reversed_dendrite = reversed_dendrite;
result.days = days;
result.dendritic_length = dendritic_length;
result.puncta_density = puncta_density;
result.puncta_intensities = puncta_intensities;
result.puncta_ranking = puncta_ranking;
result.puncta_ranking_motility = puncta_ranking_motility;
result.puncta_per_stack = puncta_per_stack;
result.puncta_per_stack_present = puncta_per_stack_present;
result.puncta_per_stack_rank = puncta_per_stack_rank;
result.puncta_per_stack_intensities = puncta_per_stack_intensities;
result.stacks = stacks;
result.parameters = parameters;
result.mouse_type = mouse_type;


% parse binary puncta table into total, gain and losses
result = parse_into_total_gain_losses( result, parameters);

% take mean dendrite length over all time points
dl = nanmean(result.dendritic_length,2);
dl = repmat(dl,1,size(result.dendritic_length,2));
result.density = result.total./dl; % Density (per um)
result.gain_per_length = result.gain./dl;
result.loss_per_length = result.loss./dl;

result.rows = (mean(result.total,2) >result.parameters.minimum_puncta_per_dendrite); % select dendrites with at least X puncta





function result = parse_into_total_gain_losses(result,parameters)



puncta = result.puncta;
dendrites = result.dendrites;
days = result.days;
stacks = result.stacks;




total = nan* zeros(length(stacks),length(days));
gain = nan* zeros(length(stacks),length(days));
loss = nan* zeros(length(stacks),length(days));
persisting = nan* zeros(length(stacks),length(days));
reappearing = nan* zeros(length(stacks),length(days));

total_big_puncta = total;
gain_big_puncta = gain;
loss_big_puncta = loss;

for d = 1:length(dendrites)
    if ~isempty(puncta{d})
        mouse = dendrites{d}(1:find(dendrites{d}==':',1)-1);
        stack = dendrites{d}(find(dendrites{d}==':',1)+1 : find(dendrites{d}==':',1,'last')-1);
        stack_nr = strmatch([mouse ':' stack],stacks);
        
        total(d,:) = sum(puncta{d});
        
        recorded_timepoints = find(~isnan(puncta{d}(1,:)));
        big_puncta{d} = (puncta{d} & (result.puncta_per_stack_rank{stack_nr}>parameters.big));
        total_big_puncta(d,:) = sum(big_puncta{d});

        
        persisting(d,1) = sum(puncta{d}(:,recorded_timepoints(1)));
        
        for i = 1:length(recorded_timepoints)-1
            change = puncta{d}(:,recorded_timepoints(i+1))-puncta{d}(:,recorded_timepoints(i));
            
            puncta_lost = (change<0);
            puncta_gained = (change>0);
            
            gain(d,recorded_timepoints(i+1)) = sum( puncta_gained);
            loss(d,recorded_timepoints(i+1)) = sum( puncta_lost);
            
            big_puncta_current = (result.puncta_per_stack_rank{stack_nr}(:,recorded_timepoints(i)) > parameters.big);
            big_puncta_next = (result.puncta_per_stack_rank{stack_nr}(:,recorded_timepoints(i+1)) > parameters.big);
            
            gain_big_puncta(d,recorded_timepoints(i+1)) = sum( puncta_gained & big_puncta_next);
            loss_big_puncta(d,recorded_timepoints(i+1)) = sum( puncta_lost & big_puncta_current);
            
            n_shuffles = 100;
            
            % clustering of lost puncta
            result.distance_between_lost_puncta(d,i) = distance_between_puncta( result.puncta_r{d}(puncta_lost,i,:) );
            % shuffle data
            all_puncta = find(puncta{d}(:,i));
            for shuffle = 1:n_shuffles
                all_puncta = all_puncta(randperm(length(all_puncta)));
                
                result.distance_between_shuffled_lost_puncta(d,i,shuffle) = ...
                    distance_between_puncta( result.puncta_r{d}(all_puncta(1:sum(puncta_lost)),i,:) );
            end
            result.p_cluster_lost_puncta(d,i) = ...
                sum( result.distance_between_shuffled_lost_puncta(d,i,:)<  result.distance_between_lost_puncta(d,i)) / ...
                n_shuffles;
            
            
            % clustering of gained puncta
            result.distance_between_gained_puncta(d,i) = distance_between_puncta( result.puncta_r{d}(puncta_gained,i+1,:) );
            % shuffle data
            all_puncta = find(puncta{d}(:,i+1));
            for shuffle = 1:n_shuffles
                all_puncta = all_puncta(randperm(length(all_puncta)));
                
                result.distance_between_shuffled_gained_puncta(d,i,shuffle) = ...
                    distance_between_puncta( result.puncta_r{d}(all_puncta(1:sum(puncta_gained)),i+1,:) );
            end
            result.p_cluster_gained_puncta(d,i) = ...
                sum( result.distance_between_shuffled_gained_puncta(d,i,:)<  result.distance_between_gained_puncta(d,i)) / ...
                n_shuffles;
            
            
            reappearing(d,recorded_timepoints(i+1)) = ...
                sum( puncta_gained & ...
                (sum( puncta{d}(:,recorded_timepoints(1:i)),2 )>0) );
            
            
            persisting(d,recorded_timepoints(i+1)) = ...
                sum(( puncta{d}(:,recorded_timepoints(i+1))>0 & ...
                puncta{d}(:,recorded_timepoints(1))>0));
        end
    end
end


result.total = total;
result.gain = gain;
result.loss = loss;
result.total_big_puncta = total_big_puncta;
result.gain_big_puncta = gain_big_puncta;
result.loss_big_puncta = loss_big_puncta;
result.persisting = persisting;
result.reappearing = reappearing;


function d = distance_between_puncta( r )
r = squeeze( r );
n_puncta = size(r,1);
d = 0;
for i = 1:n_puncta
    for j=i+1:n_puncta
        d = d + sum( (r(i,:)-r(j,:)).^2);
    end
end
d = d /  ( n_puncta * (n_puncta-1) / 2);




