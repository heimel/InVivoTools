
global pooled 
%pool neurites
% experiment 11.12_rr_101

%load graphdb
[db,filename] = load_graphdb;

%load groupdb
groupdb=load_groupdb;

[testdb.db, testdb.filename] = load_testdb('tp');

strgroups = {'11.12 lesion','11.12 lesion'};
n_groups = length(strgroups);
groups = cell(n_groups,1);
    for g=1:n_groups
        ind_g = structfind(groupdb,'name',strgroups{g});
        groups(g)= {groupdb(ind_g).filter};
    end

Poolfor = '(measures.bouton==1|measures.t_bouton==1)'; 
time = '0';
pool_short_neurites = 5;



%%

allgroups = struct([]);
for g=1:n_groups
    disp(['Group: ', num2str(g), ' ..............'])
    strmice = strsplit(groups{g}, '|');
    strmice = strrep(strmice, 'mouse=', '');
    allgroups(g).groups = strmice;
    allgroups(g).linked2neurite = [];
    allgroups(g).pooled = [];
    Cnt = 0;
    
    for i_mouse=1:length(strmice)
        disp(['Mouse: ' strmice{i_mouse}])
        indtests = structfind(testdb.db,'mouse',strmice{i_mouse});
        for i_record = indtests
            linked2neurite=[];
            dbrec = testdb.db(i_record);
            timepoint = ['day' time];
            if isfield(dbrec, 'slice')
                strday = dbrec.slice;
                if ~strcmp(timepoint, strday)
                    %reject this record
                    disp(['Record : ' num2str(i_record) ' non valid timepoint: ' strday ])
                    continue
                else
                    disp(['Record : ' num2str(i_record) ' valid' ])
                end
            end
            
            %get all rois in measurement table according to measure criteria
            Rois = dbrec.measures;
            
            for i_measure=1:length(Rois)
                measures = Rois(i_measure);
                err = 0;
                try
                    evaluated_criteria = eval(Poolfor);
                catch errmsg
                    err = 1;
                    disp('Failed to evaluate criteria')
                end
                if ~isempty(evaluated_criteria) && ~err && evaluated_criteria %bouton or t_bouton
                    linked2neurite = [linked2neurite measures.linked2neurite];
                    
                end
            end
            Cnt = Cnt + 1;
            allgroups(g).linked2neurite{Cnt,1} = linked2neurite;
            allgroups(g).linked2neurite{Cnt,2} = dbrec.mouse;
            allgroups(g).linked2neurite{Cnt,3} = dbrec.stack;
            disp(['Cnt = ', num2str(Cnt)]) 
        end %records for each mouse
    end % mouse
end %group

%%

for i = 1:length(allgroups(:))
    for j = 1:length(allgroups(i).linked2neurite) 
        nids = allgroups(i).linked2neurite{j,1}; 
        uniqneurites = unique(nids);
        Cnt = 0;
        Set = [];
        Lset = [];
        for neurite = uniqneurites(:)'
            Nix = find(nids == neurite);
            Ln = length(Nix);
            if  ~isempty(Nix)
                if Ln >= pool_short_neurites
                    Cnt = Cnt + 1;
                    Set{Cnt}  = neurite;
                    Lset{Cnt} = Ln;
                    
                elseif Cnt > 0
                    bAdd = 0; %added to short neurite?
                    for k = 1:Cnt
                        if Lset{k} < pool_short_neurites
                            Set{k} = [Set{k} neurite];
                            Lset{k} = Lset{k} + Ln;
                            bAdd = 1;
                            break
                        end
                    end
                    if ~bAdd %no => make new
                        Cnt = Cnt + 1;
                        Set{Cnt}  = neurite;
                        Lset{Cnt} = Ln;
                        
                    end
                else
                    Cnt = Cnt + 1;
                    Set{Cnt}  = neurite;
                    Lset{Cnt} = Ln;
                end
            end
        end
        if Cnt > 1
            lngval = [Lset{:}];
            [~, idx] = sort(lngval);
            if  lngval(idx(1)) < pool_short_neurites
                    Set{idx(2)} = [Set{idx(2)} Set{idx(1)}];
                    Lset{idx(2)} = Lset{idx(2)} + Lset{idx(1)};
                    Set = Set(idx(2:end));
                    Lset = Lset(idx(2:end));                      
           end
        end
        allgroups(i).pool{j}.Set = Set;
        allgroups(i).pool{j}.Lset = Lset;
    end %each stack
end %each group0

pooled.all = allgroups;