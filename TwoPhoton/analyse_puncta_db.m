function [filename,fig,h] = analyse_puncta_db(mouse_type,puncta_type,puncta_size,group_by,filename,which_punctadb)
%ANALYSE_PUNCTA_DB
%
% 2011, Alexander Heimel
%
global savepth

if nargin<1, mouse_type = ''; end
if nargin<2, puncta_type = ''; end
if nargin<3, puncta_size = ''; end
if nargin<4, group_by = ''; end
if nargin<5, filename = ''; end
if nargin<6, which_punctadb = ''; end

if isempty(mouse_type)
    mouse_type = 'md'; % 'md','all','control'
end
if isempty(puncta_type)
    puncta_type = 'synapse'; %'synapse','all','shaft','spine'
end
if isempty(puncta_size)
    puncta_size = 'all'; %'large','medium','small','all'
end
if isempty(group_by)
    group_by = 'dendrite'; % mouse,stack_hash,neurite_hash,punctum
end
if isempty(filename)
    filename=fullfile(tempdir,['puncta_data_' mouse_type '_' puncta_type '_' puncta_size '_' group_by]);
end
punctadb_filename = 'puncta_db';
if ~isempty(which_punctadb)
    punctadb_filename = [punctadb_filename  '_' which_punctadb];
    filename=fullfile(tempdir,['puncta_data_' mouse_type '_' puncta_type '_' puncta_size '_' group_by '_' which_punctadb]);
end

disp(['ANALYSE_PUNCTA_DB: ' mouse_type ', ' puncta_type ', ' ...
    puncta_size ', ' group_by ]);

switch lower(mouse_type)
    case 'md'
        crit = ['(mouse=10.24.1.25,stack=tuft1)' ...
            '|(mouse=10.24.1.25,stack=tuft2)' ...
            '|(mouse=10.24.1.25,stack=tuft3)' ...
            '|(mouse=10.24.1.26,stack=tuft1)' ...
            '|(mouse=10.24.1.27,stack=tuft1)' ...
            '|(mouse=10.24.1.27,stack=tuft2)' ...
            '|(mouse=10.24.1.28,stack=tuft1)' ... % no spine data?
            '|(mouse=10.24.1.28,stack=tuft3)' ... % no spine data yet
            ];
    case 'mono'
        crit = ['(mouse=10.24.2.38,stack=tuft3-mono)' ...
         '|(mouse=10.24.2.40,stack=tuft3-mono)' ...
           '|(mouse=10.24.2.40,stack=tuft4-mono)' ...
            '|(mouse=10.24.1.28,stack=tuft4-mono)'...
            '|(mouse=10.24.2.70,stack=tuft2)'... % last timepoint is missing
            ];
    case 'control'
        crit = ['(mouse=10.24.2.38,stack=tuft2)' ...
            '|(mouse=10.24.2.38,stack=tuft1)' ...
            '|(mouse=10.24.2.18,stack=tuft2)' ...
            '|(mouse=10.24.2.40,stack=tuft1)'...
            '|(mouse=10.24.2.40,stack=tuft2)' ] ;
    case 'repeated'
        crit = [   '(mouse=10.24.2.56,stack=tuft1,slice=day0)' ...
             '|mouse=10.24.2.56,stack=tuft1,slice=day4' ...     
             '|mouse=10.24.2.56,stack=tuft1,slice=day8' ...
             '|mouse=10.24.2.56,stack=tuft1,slice=day12' ...
             '|mouse=10.24.2.56,stack=tuft1,slice=day16' ...
             '|mouse=10.24.2.56,stack=tuft1,slice=day20' ...
             '|mouse=10.24.2.56,stack=tuft1,slice=day24' ...
             ];
    case 'all'
        crit = 'mouse=10.24*';
end

savepth = '~/Projects/Gephyrin/Figures';
[~,~] = mkdir(savepth,capitalize(mouse_type));
savepth = fullfile(savepth,capitalize(mouse_type));
[~,~] = mkdir(savepth,capitalize(puncta_type));
savepth = fullfile(savepth,capitalize(puncta_type));
[~,~] = mkdir(savepth,capitalize(group_by));
savepth = fullfile(savepth,capitalize(group_by));

days = 0:4:28;
n_days = length(days);

% load puncta db
puncta_db = [];
p=load(fullfile(expdatabasepath,punctadb_filename));
if isfield(p,'db')
    puncta_db = p.db;
else
    puncta_db = p.puncta_db; % deprecated 2012-07-01
end
    
% select mice
puncta_db = puncta_db(find_record(puncta_db,crit));

mice = unique({puncta_db.mouse});
n_mice = length(mice);
stack_hashes = unique([puncta_db.stack_hash]);
n_stacks = length(stack_hashes);
neurite_hashes = unique([puncta_db.neurite_hash]);
n_neurites = length(neurite_hashes);
n_puncta = length(puncta_db);

% basic statistics
disp('**************************');
disp(['MOUSE_TYPE = ' mouse_type]);
disp(['n_mice = ' num2str(n_mice)]);
disp(['n_stacks = ' num2str(n_stacks)]);
disp(['n_neurites = ' num2str(n_neurites)]);
disp(['n_puncta = ' num2str(n_puncta)]);


switch group_by
    case 'mouse'
        n = n_mice;
        selection = mice;
    case {'stack_hash','stack'}
        group_by = 'stack_hash';
        n = n_stacks;
        selection = cellfun(@num2str,num2cell(stack_hashes),'uniformoutput',false);
    case {'neurite_hash','dendrite','neurite','axon','line'}
        group_by = 'neurite_hash';
        n = n_neurites;
        selection = cellfun(@num2str,num2cell(neurite_hashes),'uniformoutput',false);
    case 'punctum'
        n = 1;
        selection = '';
end

if isempty(selection)
    for i=1:n
        selection{i}='';
    end
else
    for i=1:n
        selection{i} = [  group_by '=' selection{i}];
    end
end

disp('ANALYSE_PUNCTA_DB: assuming experiment 10.24');
all_puncta_types = tpstacktypes(struct('experiment','10.24'));
%n_puncta_types = length(all_puncta_types);


switch puncta_type
    case 'all'
        puncta_type_ind = [];
    case 'synapse'
        puncta_type_ind = strmatch('spine',all_puncta_types);
        puncta_type_ind(end+1) = strmatch('shaft',all_puncta_types);
    otherwise
        puncta_type_ind = strmatch(puncta_type,all_puncta_types);
        disp(['ANALYSE_PUNCTA_DB: Only analyzing ' all_puncta_types{puncta_type_ind} ' puncta.']);
        
end

gained = cell(n,1);
lost = cell(n,1);
present = cell(n,1);
right_type = cell(n,1);
lostyesterday = cell(n,1);

for i = 1:n
    db = puncta_db(find_record(puncta_db,selection{i}));
    
    switch group_by
        case 'mouse'
            groupname{i} =  ['mouse=' db(1).mouse ];
        case 'stack_hash'
            groupname{i} =  ['mouse=' db(1).mouse ',stack=' db(1).stack ];
        case 'neurite_hash'
            groupname{i} =  ['mouse=' db(1).mouse ',stack=' db(1).stack ',neurite=' num2str(db(1).neurite)];
        case 'punctum'
            groupname{i} = 'punctum';
    end
    disp(['ANALYSE_PUNCTA_DB: ' selection{i} ', Group ' num2str(i) ' = ' groupname{i} ]);
    if ~isempty(db)
        n_days = length(db(1).present);
    end
    present{i} = reshape([db.present],n_days,length(db))';
    lost{i} = reshape([db.lost],n_days,length(db))';
    tobelost{i} = reshape([db.tobelost],n_days,length(db))';
    gained{i} = reshape([db.gained],n_days,length(db))';
    tobegained{i} = reshape([db.tobegained],n_days,length(db))';
    lostyesterday{i}(1:length(db),1) = false;
    lostyesterday{i}(:,2:n_days) = lost{i}(:,1:end-1) & ~present{i}(:,2:end);
    
    % get right_type
    if ~isempty(puncta_type_ind)
        
        right_type{i} = false(size(present{i}));
        for j=1:length(puncta_type_ind)
            right_type{i} = right_type{i} | reshape([db.type]==puncta_type_ind(j),n_days,length(db))';
        end
    else
        right_type{i} = true(size(present{i}));
    end
    
    
    GFP{i} = reshape(bitand([db.labels],1)>0,n_days,length(db))'; % spine still present
    RFP{i} = reshape(bitand([db.labels],2)>0,n_days,length(db))'; % lost stubby spine
    lostspine{i} = reshape(bitand([db.labels],4)>0,n_days,length(db))'; % lost mushroom spine
    
    persisting_from_day_until{i} = reshape([db.persisting_from_day_until],n_days,length(db))'; %#ok<NASGU>
    
    stubby_absent{i} = RFP{i};
    mushroom_absent{i} = lostspine{i};
    spine_absent{i} = stubby_absent{i}|mushroom_absent{i};
    
    % report spine inconsistencies and fill in spine gained and lost
    if strcmp(puncta_type,'spine')
        punctum_present_spine_absent = (~GFP{i}(:,:) & present{i}(:,:)); 
        spine_inconsistent = spine_absent{i} & GFP{i};
        if any(punctum_present_spine_absent(:)) || any(spine_inconsistent(:)) % i.e. inconsistent
            [pind,dind] = find(punctum_present_spine_absent | spine_inconsistent);
            for j=1:length(pind)
                disp(['ANALYSE_PUNCTA_DB: mouse=' db(pind(j)).mouse ...
                    ',stack=' db(pind(j)).stack ',timepoint=' num2str(dind(j)) ...
                    ',ROI_index=' num2str(db(pind(j)).index) ' is inconsistently labeled']);
            end
        end
        spine_present{i} = right_type{i} & ~spine_absent{i};
        spine_lost{i}  = false(size(spine_present{i}));
        spine_lost{i}(:,2:end) = spine_present{i}(:,1:end-1) & ~spine_present{i}(:,2:end);
        spine_gained{i} = false(size(spine_present{i}));
        spine_gained{i}(:,2:end) = ~spine_present{i}(:,1:end-1) & spine_present{i}(:,2:end);
    end
        
    for k=1:n_days
        persisting{k,i} = zeros(size(present{i}));
        persisting{k,i}(:,k) = present{i}(:,k);
        for j=(k+1):n_days
            persisting{k,i}(:,j) = persisting{k,i}(:,j-1) & present{i}(:,j);
        end
    end
    
    intensity_red{i} = reshape([db.intensity_red],n_days,length(db))';
    intensity_green{i} = reshape([db.intensity_green],n_days,length(db))';
    
    % rank puncta, only makes sense per dendrite or stack
    intensity_rank{i} = zeros(size(intensity_green{i}));
    if size(intensity_green{i},1)>1
        for j=1:n_days
            if any( present{i}(:,j)&right_type{i}(:,j) )
            
            intensity_rank{i}(present{i}(:,j)&right_type{i}(:,j),j) =...
                ranks(intensity_green{i}(present{i}(:,j)&right_type{i}(:,j),j) ) / ...
                sum(present{i}(:,j)&right_type{i}(:,j));
            end
        end
    else
        intensity_rank{i} = ones(size(intensity_green{i}));
    end
    
    large{i} = (intensity_rank{i}>=0.5);
    small{i} = (intensity_rank{i}<0.5);
    medium{i} = (intensity_rank{i}>0.25 & intensity_rank{i}<0.75);
    
    
    switch puncta_size
        case 'all'
            % do nothing
        case 'large'
            right_type{i} = right_type{i} & large{i};
        case 'small'
            right_type{i} = right_type{i} & small{i};
        case 'medium'
            right_type{i} = right_type{i} & medium{i};
    end
    
    
    lost{i}(:,2:end) = lost{i}(:,2:end) & right_type{i}(:,1:end-1);
    gained{i} = gained{i} & right_type{i};
    present{i} = present{i} & right_type{i};
    tobelost{i} = tobelost{i} & right_type{i};
    tobegained{i}(:,1:end-1) = tobegained{i}(:,1:end-1) & right_type{i}(:,2:end);
    absent{i} = ~present{i} & right_type{i};
    lostyesterday{i} = lostyesterday{i} & right_type{i};
    
    % for persisting only check right_type at first appearance
    for k=1:n_days
        persisting{k,i} = persisting{k,i} & repmat( right_type{i}(:,k),1,n_days);
    end
    
    
    
    
    for m=1:n_days % relative to earlier day m
        for k=1:n_days % state at day k, relative to m
            %Changed next lines on 2012-02-15 to change persisting to present
            % punctum_lost_spine_lost{m,i}(:,k) = present{i}(:,m)&~persisting{m,i}(:,k) & GFP{i}(:,m) & ~GFP{i}(:,k);
            % punctum_lost_spine_persisting{m,i}(:,k) = present{i}(:,m)&~persisting{m,i}(:,k) & GFP{i}(:,m) & GFP{i}(:,k);
            % punctum_persisting_spine_persisting{m,i}(:,k) = persisting{m,i}(:,k) & GFP{i}(:,m) & GFP{i}(:,k);

            punctum_lost_spine_lost{m,i}(:,k) = present{i}(:,m) & ~present{i}(:,k) & GFP{i}(:,m) & ~GFP{i}(:,k);
            punctum_lost_spine_preexisting{m,i}(:,k) = present{i}(:,m) & ~present{i}(:,k) & GFP{i}(:,m) & GFP{i}(:,k);
            punctum_persisting_spine_preexisting{m,i}(:,k) = present{i}(:,m) & persisting{m,i}(:,k) & GFP{i}(:,m) & GFP{i}(:,k);
            punctum_preexisting_spine_preexisting{m,i}(:,k) = present{i}(:,m) & present{i}(:,k) & GFP{i}(:,m) & GFP{i}(:,k);
        end
    end
    
    
    for m=1:n_days % from later day m
        for k=1:n_days % state at day k, relative to m
            %Changed next lines on 2012-02-15 to change persisting to present
            % punctum_new_spine_new{m,i}(:,k) = present{i}(:,m) &~persisting{k,i}(:,m) & GFP{i}(:,m) & ~GFP{i}(:,k);
            % punctum_new_spine_preexisting{m,i}(:,k) = present{i}(:,m) &~persisting{k,i}(:,m) & GFP{i}(:,m) &  GFP{i}(:,k);
            % punctum_preexisting_spine_preexisting{m,i}(:,k) =  present{i}(:,m)     &    persisting{k,i}(:,m) & GFP{i}(:,m) &  GFP{i}(:,k);

            punctum_new_spine_new{m,i}(:,k) =         present{i}(:,m) & ~present{i}(:,k) & GFP{i}(:,m) & ~GFP{i}(:,k);
            punctum_new_spine_preexisting{m,i}(:,k) = present{i}(:,m) & ~present{i}(:,k) & GFP{i}(:,m) &  GFP{i}(:,k);
            punctum_preexisting_spine_preexisting{m,i}(:,k) =  present{i}(:,m) & present{i}(:,k) & GFP{i}(:,m) &  GFP{i}(:,k);
        end
        
    end
    
       
    
    puncta_absent_spineabsent{i}     = absent{i} & spine_absent{i};
    puncta_tobegained_spineabsent{i} = tobegained{i} & spine_absent{i};
    puncta_gained_spineabsent{i}     = gained{i} & spine_absent{i};
    puncta_present_spineabsent{i}     = present{i} & spine_absent{i};
    puncta_tobelost_spineabsent{i}     = tobelost{i} & spine_absent{i};
    puncta_lost_spineabsent{i}     = lost{i} & spine_absent{i};
    puncta_lost_spinepresent{i}    = lost{i} & ~spine_absent{i};
    puncta_lostyesterday_spineabsent{i} = lostyesterday{i} & spine_absent{i};
    
    puncta_no_spine_no{i} = (spine_absent{i}&~present{i}&right_type{i});
    puncta_no_spine_yes{i} = (~spine_absent{i}&~present{i}&right_type{i});
    
    puncta_gained_spineabsent{i} = gained{i};
    puncta_gained_spinepresent{i} = gained{i};
    puncta_gained_spineabsent{i}(:,2:end) = gained{i}(:,2:end) & spine_absent{i}(:,1:end-1);
    puncta_gained_spinepresent{i}(:,2:end) = gained{i}(:,2:end) & ~spine_absent{i}(:,1:end-1);

    if n_days>1
        lost_during_md{i} = lost{i}(:,3)|lost{i}(:,4)|lost{i}(:,5);
        lost_and_regained_during_md{i} = (lost{i}(:,3)|lost{i}(:,4)) & (present{i}(:,5));
        persisting_throughout_md{i} = persisting{2,i}(:,5); 
        gained_after_reopening{i} = gained{i}(:,6)|gained{i}(:,7); 
        lost_after_reopening{i} = lost{i}(:,6)|lost{i}(:,7); 
        regained_after_reopening{i} = lost_during_md{i} & gained_after_reopening{i};

        
        
    else
        lost_during_md{i} = false(length(db),1);
        gained_after_reopening{i} = false(length(db),1);
        regained_after_reopening{i} = false(length(db),1);
    end
    
    % if strcmp(group_by,'neurite_hash')
    hashes = zeros(length(db),1);
    for j=1:length(db)
        hashes(j) =pm_hash('crc',[db(j).mouse ',' db(j).stack ',' num2str(db(j).neurite)]);
    end
    hashes = unique(hashes);
    
    neurite_length(i,:) = zeros(1,n_days);
    for j = 1:length(hashes)
        temp = reshape([db.type],n_days,length(db));
        neurite_roi = db(temp(1,:) == 5 & [db.neurite_hash] == hashes(j));
        if ~isempty(neurite_roi)
            neurite_length(i,:) = neurite_length(i,:) + nanmean(neurite_roi.distance)*ones(1,n_days);
        end
        if any(neurite_length(i,:)==0)
            disp(['ANALYSE_PUNCTA_DB: ' groupname{i} ' neurite ' num2str(hashes(j)) ' has zero length or is not present']);
            neurite_length(i,:) = NaN(1,size(neurite_length,2));
        end
    end
    
end
total_lost = get_total(lost);
total_gained = get_total(gained);
total_present = get_total(present);
total_right = get_total(right_type);
total_lost_spine_absent = get_total(puncta_lost_spineabsent);
total_lost_spine_present = get_total(puncta_lost_spinepresent);
total_gained_spine_absent = get_total(puncta_gained_spineabsent);
total_gained_spine_present = get_total(puncta_gained_spinepresent);


if strcmp(puncta_type,'spine')
    total_spine_lost = get_total(spine_lost); % real spines, not spine puncta!
    total_spine_gained = get_total(spine_gained);
    total_spine_present = get_total(spine_present);
end


disp(['n_' puncta_type '_puncta = ' num2str(median(sum(total_right)))]);

for k=1:n_days
    total_persisting{k} = get_total({persisting{k,:}});
    
    total_punctum_lost_spine_lost{k}= get_total({punctum_lost_spine_lost{k,:}});
    total_punctum_lost_spine_preexisting{k} = get_total({punctum_lost_spine_preexisting{k,:}});
    total_punctum_persisting_spine_preexisting{k} = get_total({punctum_persisting_spine_preexisting{k,:}});
    total_punctum_preexisting_spine_preexisting{k} = get_total({punctum_preexisting_spine_preexisting{k,:}});
    
    total_punctum_new_spine_new{k}= get_total({punctum_new_spine_new{k,:}});
    total_punctum_new_spine_preexisting{k} = get_total({punctum_new_spine_preexisting{k,:}});
    total_punctum_preexisting_spine_preexisting{k} = get_total({punctum_preexisting_spine_preexisting{k,:}});
    
end
total_right_type = get_total(right_type);
total_puncta_no_spine_no = get_total(puncta_no_spine_no);
total_puncta_no_spine_yes = get_total(puncta_no_spine_yes);

total_lost_during_md = cellfun(@sum,lost_during_md);
total_gained_after_reopening = cellfun(@sum,gained_after_reopening);
total_regained = cellfun(@sum,regained_after_reopening);

% regained after reopening versus lost and gained during MD
regained_relative2lost = total_regained./total_lost_during_md;
disp(['Regained relative to lost = ' num2str(nanmean(regained_relative2lost)) ...
    ' +- ' num2str(sem(regained_relative2lost)) ]);
regained_relative2gained = total_regained./total_gained_after_reopening;
disp(['Regained relative to gained = ' num2str(nanmean(regained_relative2gained)) ...
    ' +- ' num2str(sem(regained_relative2gained)) ]);



% spine history
total_puncta_absent_sa = get_total(puncta_absent_spineabsent)./get_total(absent) ;
total_puncta_tobegained_sa = get_total(puncta_tobegained_spineabsent)./get_total(tobegained);
total_puncta_gained_sa = get_total(puncta_gained_spineabsent)./get_total(gained);
total_puncta_present_sa = get_total(puncta_present_spineabsent)./get_total(present);
total_puncta_tobelost_sa = get_total(puncta_tobelost_spineabsent)./get_total(tobelost);
total_puncta_lost_sa = get_total(puncta_lost_spineabsent)./get_total(lost);
total_puncta_lostyesterday_sa = get_total(puncta_lostyesterday_spineabsent)./get_total(lostyesterday);

mean_puncta_history(:,1) = nanmean(total_puncta_absent_sa,2);
mean_puncta_history(:,2) = nanmean(total_puncta_tobegained_sa,2);
mean_puncta_history(:,3) = nanmean(total_puncta_gained_sa,2);
mean_puncta_history(:,4) = nanmean(total_puncta_present_sa,2);
mean_puncta_history(:,5) = nanmean(total_puncta_tobelost_sa,2);
mean_puncta_history(:,6) = nanmean(total_puncta_lost_sa,2);
mean_puncta_history(:,7) = nanmean(total_puncta_lostyesterday_sa,2);
mean_puncta_history(:,8) = nanmean(total_puncta_absent_sa,2);

history_rows = nanmean(mean_puncta_history,2)>0.005;
if 0 && strcmp(puncta_type,'spine')
    show_results( (1-mean_puncta_history(history_rows,:))*100,'Spine history (mean)',(1:size(mean_puncta_history,2)),false,true,[],[0 0 0],true);
    set(gca,'XTickLabel',{'absent','to be gained','gained','present','to be lost','lost','lost before','absent'})
    ylabel('Spine present (%)');
    xlabel('Punctum')
end




if 0 && strcmp(puncta_type,'spine')
    early_puncta_history(:,1) = total_puncta_absent_sa(:,2);
    early_puncta_history(:,2) = total_puncta_tobegained_sa(:,2);
    early_puncta_history(:,3) = total_puncta_gained_sa(:,2);
    early_puncta_history(:,4) = total_puncta_present_sa(:,2);
    early_puncta_history(:,5) = total_puncta_tobelost_sa(:,2);
    early_puncta_history(:,6) = total_puncta_lost_sa(:,2);
    early_puncta_history(:,7) = total_puncta_absent_sa(:,2);
    show_results( (1-early_puncta_history(history_rows,:))*100,'Spine history (before MD)',(1:7),false,true,[],[0 0 0],true);
    set(gca,'XTickLabel',{'absent','to be gained','gained','present','to be lost','lost','absent'})
    ylabel('Spine present (%)');
    xlabel('Punctum')
end

% persisting vs intensity
if 0
    figure 
    hold on
    tp = 2;
    rank_pool = [];
    persisting_pool = [];
    for i=1:length(intensity_rank)
        plot(  intensity_rank{i}(present{i}(:,tp),tp),...
            4*(persisting_from_day_until{i}(present{i}(:,tp),tp)-1), ...
            'o');
        
        rank_pool = [rank_pool; intensity_rank{i}(present{i}(:,tp),tp)];
        persisting_pool = [persisting_pool; 4*(persisting_from_day_until{i}(present{i}(:,tp),tp)-1)];
    end
    xlabel([capitalize(puncta_type) ' synapse rank']);
    ylabel('Persisting from day 4 until');
    figfilename = [capitalize(puncta_type) ' synapse rank vs persistence'];
    save_figure(figfilename,'~/Desktop');
    [r,p] =corrcoef(rank_pool,persisting_pool)
    disp(['ANALYSE_PUNCTA_DB: Crosscorrelation between persistance length and rank = ' num2str(r(1,2)) ', sig diff zero, p = ' num2str(p(2,1))])
end

% puncta size vs dynamics
green_history = [];
for i = 1:length(intensity_green)
    
    green_history(i,1) = nanmean(intensity_green{i}(absent{i}));
    green_history(i,2) = nanmean(intensity_green{i}(tobegained{i}));
    green_history(i,3) = nanmean(intensity_green{i}(gained{i}));
    green_history(i,4) = nanmean(intensity_green{i}(present{i}));
    green_history(i,5) = nanmean(intensity_green{i}(tobelost{i}));
    green_history(i,6) = nanmean(intensity_green{i}(lost{i}));
    green_history(i,7) = nanmean(intensity_green{i}(lostyesterday{i}));
    green_history(i,8) = nanmean(intensity_green{i}(absent{i}));
    %green_history = thresholdlinear(green_history);
end

if 0
    [fig.green,h.green] = show_results( green_history,['Green signal for ' puncta_type ' synapses'],1:size(green_history,2),false,true,[],[0 1 0],false); %#ok<*UNRCH>
    set(gca,'XTickLabel',{'absent','to be gained','gained','present','to be lost','lost','lost before','absent'})
    ylabel('Raw intensity');
end

red_history = [];
for i = 1:length(intensity_green)
    red_history(i,1) = nanmean(intensity_red{i}(absent{i}));
    red_history(i,2) = nanmean(intensity_red{i}(tobegained{i}));
    red_history(i,3) = nanmean(intensity_red{i}(gained{i}));
    red_history(i,4) = nanmean(intensity_red{i}(present{i}));
    red_history(i,5) = nanmean(intensity_red{i}(tobelost{i}));
    red_history(i,6) = nanmean(intensity_red{i}(lost{i}));
    red_history(i,7) = nanmean(intensity_red{i}(lostyesterday{i}));
    red_history(i,8) = nanmean(intensity_red{i}(absent{i}));
    %red_history = thresholdlinear(red_history);
    
end

if 0
    [fig.red,h.red] = show_results( red_history,['Red signal for ' puncta_type ' synapses'],1:size(red_history,2),false,true,[],[1 0 0],false);
    set(gca,'XTickLabel',{'absent','to be gained','gained','present','to be lost','lost','lost before','absent'})
    ylabel('Intensity (norm. to dendrite)');
end

% group small groups
if ~strcmp(group_by,'punctum')
    switch puncta_type
        case 'synapse'
            min_per_group = 9; %
        case 'spine'
            min_per_group = 9;
        case 'shaft'
            min_per_group = 9;
        case 'all'
            min_per_group = 9;
        otherwise
            error(['ANALYSE_PUNCTADB: Unknown group_by type ' group_by ]);
    end
    if findstr(which_punctadb,'rajeev')
        disp('ANALYSE_PUNCTA_DB: Setting min_per_group to 0');
        min_per_group = 0;
    end
    
    small_groups = (mean(total_right_type,2)<min_per_group);
    
    % added add_to_end, on 2012-02-13 to avoid adding a new group that is
    % too small
    add_to_end =  sum(mean(total_right_type(small_groups,:),2)>=min_per_group);
    if any(small_groups)
        total_present = remove_small_groups(total_present,small_groups,add_to_end);
        total_gained = remove_small_groups(total_gained,small_groups,add_to_end);
        total_lost = remove_small_groups(total_lost,small_groups,add_to_end);
        total_lost_spine_absent = remove_small_groups(total_lost_spine_absent,small_groups,add_to_end);
        total_lost_spine_present = remove_small_groups(total_lost_spine_present,small_groups,add_to_end);
        total_gained_spine_absent = remove_small_groups(total_gained_spine_absent,small_groups,add_to_end);
        total_gained_spine_present = remove_small_groups(total_gained_spine_present,small_groups,add_to_end);
        
        for k=1:n_days
            total_persisting{k} = remove_small_groups(total_persisting{k},small_groups,add_to_end);
        end
        total_right_type = remove_small_groups(total_right_type,small_groups,add_to_end);
        total_puncta_no_spine_no = remove_small_groups(total_puncta_no_spine_no,small_groups,add_to_end);
        total_puncta_no_spine_yes = remove_small_groups(total_puncta_no_spine_yes,small_groups,add_to_end);
        neurite_length = remove_small_groups(neurite_length,small_groups,add_to_end);
        groupname = remove_small_groups( groupname, small_groups,add_to_end);

        if strcmp(puncta_type,'spine')
            total_spine_present = remove_small_groups(total_spine_present,small_groups,add_to_end);
            total_spine_gained = remove_small_groups(total_spine_gained,small_groups,add_to_end);
            total_spine_lost = remove_small_groups(total_spine_lost,small_groups,add_to_end);
        end
        
        small_group_selection = selection{small_groups};
        selection = {selection{~small_groups} small_group_selection}; %#ok<NASGU>
    end
end

if n_days>7 
    n_days = 7; % cut off timepoint 8
end


% puncta density
density =  total_present./neurite_length; 
if 0
    tit = capitalize([ puncta_type ' puncta/micron']);
    [fig.density,h.density] = show_results( density(:,1:n_days),tit,days(1:n_days),false,true,[],[0 0 0],true);
    disp_results(density(:,1:n_days),groupname,tit,days(1:n_days));
end


% spine presence
if 0 && strcmp(puncta_type,'spine')
    relative_puncta_no_spine_no =   total_puncta_no_spine_no ./ total_right_type;
    relative_puncta_no_spine_yes =   total_puncta_no_spine_yes ./ total_right_type;
    
    fig.spine_presence =figure('numbertitle','off','name','Spine puncta sites');
    h.spine_presence = bar(0:4:24,[ mean(total_present(:,1:n_days)./total_right_type(:,1:n_days)*100,1);...
        relative_puncta_no_spine_yes(:,1:n_days)*100;...
        relative_puncta_no_spine_no(:,1:n_days)*100]','stacked' );
    legend('Spine & puncta','Spine alone','No spine','location','northeastoutside')
    legend boxoff
    ylim([0 100])
    box off
    xlabel('Days');
    ylabel('Fraction of sites (%)');
    xlim([-3 26]);
    
    line( [6 18],4*[-1 -1],'linewidth',8,'color',0.2*[1 1 1],'clipping','off')
    
    save_figure('spine_puncta_bars','~/Projects/Gephyrin/Figures');
end


relative_lost = NaN(size(total_lost));
relative_lost(:,2:end) = total_lost(:,2:end)./total_present(:,1:end-1);
relative_lost_spine_absent = NaN(size(total_lost));
relative_lost_spine_absent(:,2:end) = total_lost_spine_absent(:,2:end)./total_present(:,1:end-1);
relative_lost_spine_present = NaN(size(total_lost));
relative_lost_spine_present(:,2:end) = total_lost_spine_present(:,2:end)./total_present(:,1:end-1);


relative_gained_spine_absent = NaN(size(total_gained));
relative_gained_spine_absent(:,2:end) = total_gained_spine_absent(:,2:end)./total_present(:,1:end-1);
relative_gained_spine_present = NaN(size(total_gained));
relative_gained_spine_present(:,2:end) = total_gained_spine_present(:,2:end)./total_present(:,1:end-1);


relative_gained = NaN(size(total_lost));
relative_gained(:,2:end) = total_gained(:,2:end)./total_present(:,2:end);
        

if strcmp(puncta_type,'spine')
    relative_spine_lost = NaN(size(total_spine_lost));
    relative_spine_lost(:,2:end) = total_spine_lost(:,2:end)./total_spine_present(:,1:end-1);
    relative_spine_gained = NaN(size(total_spine_lost));
    relative_spine_gained(:,2:end) = total_spine_gained(:,2:end)./total_spine_present(:,2:end);
end

% persistance
for k=1:n_days
    rel_persisting{k} = total_persisting{k} ./ repmat(total_present(:,k),1,size(total_present,2));
end
if 0
    tit = ['Persisting ' puncta_type ' puncta (%)'];
    [fig.pers,h.pers] = show_results( rel_persisting{1}(:,1:n_days)*100,tit,days(1:n_days),false,true,[],[0 0 0],true);
    disp_results(rel_persisting{1}(:,1:n_days),groupname,tit,days(1:n_days));
end

% gain & loss
if 0
    [fig.loss,h.loss] = show_results( relative_lost(:,2:n_days)*100,['Gain and Loss ' puncta_type ' puncta (%)'],days(2:n_days),false,true,[],[0 0 1],true);
    [fig.gain,h.gain] = show_results( relative_gained(:,2:n_days)*100,['Gain and Loss ' puncta_type ' puncta (%)'],days(2:n_days),false,true,fig.loss,[1 0 0],true,mouse_type);
    legend([h.loss,h.gain],'Loss','Gain','location','northwest')
    legend boxoff
    ylim([0 30])
end

% chi2 test
if strcmp(group_by,'punctum')
    for t=2:7
        p_lost(t) = chi2class([total_present(1)-total_lost(2) total_lost(2);total_present(t)-total_lost(t+1) total_lost(t+1)]);
        star = '';
        if p_lost(t)<0.001, star = '***';
        elseif p_lost(t)<0.01, star = '**';
        elseif p_lost(t)<0.05, star = '*';
        end
        text(days(t+1),nanmean(relative_lost(:,t+1))*100+2,star,'fontsize',16,'horizontalalignment','center','color',[0 0 1])
        
        p_gained(t) = chi2class([total_present(2)-total_gained(2) total_gained(2);total_present(t+1)-total_gained(t+1) total_gained(t+1)]);
        star = '';
        if p_gained(t)<0.001, star = '***';
        elseif p_gained(t)<0.01, star = '**';
        elseif p_gained(t)<0.05, star = '*';
        end
        text(days(t+1),nanmean(relative_gained(:,t+1))*100-2,star,'fontsize',16,'horizontalalignment','center','color',[1 0 0])
    end
    for t=2:8
        p_lost_vs_gained(t) = chi2class([total_present(t-1)-total_lost(t) total_lost(t);total_present(t)-total_gained(t) total_gained(t)]);
        star = '';
        if p_lost_vs_gained(t)<0.001, star = '***';
        elseif p_lost_vs_gained(t)<0.01, star = '**';
        elseif p_lost_vs_gained(t)<0.05, star = '*';
        end
        text(days(t), (nanmean( relative_lost(:,t))+nanmean( relative_gained(:,t)))*50-1,star,'fontsize',16,'horizontalalignment','center','color',[0 0 0])
    end
    disp(['timepoints = ' mat2str(0:4:28)]);
    disp(['p_lost = ' mat2str(p_lost,1)]);
    disp(['p_gained = ' mat2str(p_gained,1)]);
    disp(['p_lost_vs_gained = ' mat2str(p_lost_vs_gained,1)]);
end


if strcmp(group_by,'punctum')
    % time of presence (of next 7 timepoints) if present at 1st timepoint
    age_since_start = sum(present{1}(:,1:7),2);
    disp(['Puncta which are present at day 0, are present at ' ...
        num2str(mean(age_since_start(present{1}(:,1))),2) '+-' ...
        num2str(sem(age_since_start(present{1}(:,1))),2) ' tp of the first 7 timepoints']);
    
    
    % time of presence (of next 7 timepoints) if gained at 2nd timepoint
    age_since_day4 = sum(present{1}(:,2:8),2);
    disp(['Puncta which are gained at day 4, are present at ' ...
        num2str(mean(age_since_day4( gained{1}(:,2))),2) '+-' ...
        num2str(sem(age_since_day4( gained{1}(:,2))),2) ' tp of the next 7 timepoints']);
end

% result = [];
% vars = whos;
% for i=1:length(vars)
%     result.(vars(i).name) = eval(vars(i).name);
% end

save(filename);



function [hfig,hplot] = show_results( data,ylab,days,plotpoints,plotmean,fig,clr,plotsig,mouse_type )
global savepth

if nargin<4
    plotpoints = true;
end
if nargin<5
    plotmean = true;
end
if nargin<6
    fig = [];
end
if isempty(fig)
    hfig = figure('name',ylab,'NumberTitle','off');
else
    hfig = fig;
end
if nargin<7
    clr = [];
end
if nargin<8
    plotsig = true;
end
if nargin<9
    mouse_type = '';
end

% take out completely zero rows
nonzero_rows = (nansum(abs(data),2)>0);
data = data(nonzero_rows,:);

hold on

if plotmean
    if numel(data)~=length(data)
        hplot= errorbar(days,nanmean(data),sem(data),'k','linewidth',2);
    else
        hplot = plot(days,data,'k','linewidth',2);
    end
    if ~isempty(clr)
        set(hplot,'color',clr);
    end
    
    set(hplot,'marker','o','MarkerFaceColor',[1 1 1],'MarkerSize',8);
    ax = axis;
    ax(3) = 0;
    ax(4) = ax(4)*1.1;
    axis(ax);
end

if plotpoints
    if ~isempty(clr)
        plot(days,data','color',clr);
    else
        plot(days,data');
    end
end
ax = axis;

if ~isempty(findstr(lower(mouse_type),'md'))
    
    
    hbar = bar(7+6,ax(4)*2,12);
    set(hbar,'facecolor',0.8*[1 1 1],'linestyle','none');
    c=get(gca,'children');
    set(gca,'children',c(end:-1:1));
    text( 13,ax(4),'MD','horizontalalignment','center','verticalalignment','top');
end

axis(ax);

xlabel('Time (days)');
xlim([-0.3 max(days)]);
set(gca,'xtick',days);
ylabel(ylab);

set(gca,'tickdir','out')
box off


if plotmean && plotsig && numel(data)~=length(data)
    if isnan(data(1,1))
        for i=3:length(days)
            [~,p]=ttest( data(:,2),data(:,i)); %#ok<NASGU>
            try
                pf = friedman( [data(:,2) data(:,i)],1,'off');
            catch
                pf = NaN;
            end
            p = pf; % taking friedman
            if p<0.1
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', friedman test p = ' num2str(pf,2)  ]);
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', paired ttest p = ' num2str(p,2)  ]);
                if p<0.001
                    ch = '***';
                elseif p<0.01
                    ch = '**';
                elseif p<0.05
                    ch = '*';
                elseif p<0.1;
                    ch = '#';
                end
                if ~isempty(clr)
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20,'color',clr);
                else
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20);
                end
            end
        end
    else
        for i=2:length(days)
            [~,p]=ttest( data(:,1),data(:,i)); %#ok<NASGU>
            try
                pf = friedman( [data(:,1) data(:,i) ],1,'off');
            catch
                pf = NaN;
            end
            p = pf; % taking friedman
            if p<0.1
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', friedman test p = ' num2str(pf,2)  ]);
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', paired ttest p = ' num2str(p,2)  ]);
                if p<0.001
                    ch = '***';
                elseif p<0.01
                    ch = '**';
                elseif p<0.05
                    ch = '*';
                elseif p<0.1;
                    ch = '#';
                end
                if ~isempty(clr)
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20,'color',clr);
                else
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20);
                end
            end
            
        end
    end
end


figfilename = ylab;
save_figure(figfilename,savepth);




function y = sum1( x )
%SUM1 sums along dim 1, i.e. SUM( X, 1)
y = sum(x,1);

function y = get_total( x )



y = cellfun(@sum1,x,'UniformOutput',false);
y = cellfun(@transpose,y,'uniformoutput',false);
y = transpose([y{:}]);


function x = remove_small_groups(x,small_groups,add_to_end)
large_groups = true(size(x,1),1)&~small_groups;

if isnumeric(x)
    x = x(large_groups,:);
    if add_to_end
        small_group_x = sum(x(small_groups,:));
        x(end+1,:) = small_group_x;
    end
else
    x = {x{large_groups}};
    if add_to_end
        small_group_x = [x{small_groups}];
        x{end+1} = small_group_x;
    end
end


% function hash2neurite( hash)
% if isnumeric(hash)
%     hash = num2str(hash);
% end
% 
% puncta_db = [];
% load(fullfile(expdatabasepath,'puncta_db'));
% ind = find_record(puncta_db,['neurite_hash = ' hash]);
% if isempty(ind)
%     ind = find_record(puncta_db,['stack_hash = ' hash]);
% end
% if isempty(ind)
%     disp('ANALYSE_PUNCTA_DB: cannot resolve hash');
%     return;
% end
% record = puncta_db(ind(1));
% record.mouse
% record.stack
% record.neurite


function disp_results(x,groupname,property,days)
if nargin>2
    disp(property);
end
dlen = median(cellfun(@length,groupname));
for i = 1:length(groupname)
    disp([groupname{i}(1:min(dlen+1,end)) ': ' num2str(x(i,:),2)]);
end
if nargin>3
    disp(['Days                ' num2str(days)]);
end
disp(['Mean across ' num2str(length(groupname)) ' groups: ' num2str(nanmean(x,1),2)]);
disp(['SEM  across groups: ' num2str(sem(x),3)]);
disp(['Total mean        : ' num2str(nanmean(x(:)),4)]);
