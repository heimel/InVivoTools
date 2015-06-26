
global pooled 
%pool neurites
experiment 11.12_ls_axons

%load graphdb
[db,filename] = load_graphdb;

%load groupdb
groupdb=load_groupdb;

[testdb.db, testdb.filename] = load_testdb('tp');

strgroups = {'11.12 no lesion 3 hours early', '11.12 lesion 3 hours early'};
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
                    disp(['Record : ' num2str(i_record) ' not valid, timepoint is ' strday ])
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
                if ~err && evaluated_criteria %bouton or t_bouton
                    linked2neurite = [linked2neurite measures.linked2neurite];
                    
                end
            end
            Cnt = Cnt + 1;
            allgroups(g).linked2neurite{Cnt} = linked2neurite;
        end %records for each mouse
    end % mouse
end %group

%%

for i = 1:length(allgroups(:))
    for j = 1:length(allgroups(i).linked2neurite) 
        nids = allgroups(i).linked2neurite{j}; 
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
                            continue
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
            if  Lset{Cnt} < pool_short_neurites
                Set{Cnt-1} = [Set{Cnt-1} Set{Cnt}];
                Set = Set(1:Cnt-1);
                Lset{Cnt-1} = Lset{Cnt-1} + Lset{Cnt};
                Lset =  Lset(1:Cnt-1);
            end
        end
        allgroups(i).pool{j}.Set = Set;
        allgroups(i).pool{j}.Lset = Lset;
    end %each stack
end %each group0

pooled.all = allgroups;