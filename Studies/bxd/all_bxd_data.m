% adds all measures to bxddb
% 

cd(bxddatadir);

strains=neurobsik_strains;

mousedb=load_mousedb;
testdb=load_testdb;

ind_bxdmice=[];

bxddb_per_strain={};

% select all imaged bxd mice
for s=1:length(strains)
  fprintf([strains{s} ' ']);
  ind_strain=find_record(mousedb,['strain=' strains{s} ',actions=*oi*, (type=control 1*|type=MD 7d from p*),anesthetic=*ure*']);
  bxddb=mousedb(ind_strain);
  if ~isempty(bxddb)
    new_bxddb=get_allmeasures(bxddb(1),testdb);
    for m=2:length(bxddb)
      new_bxddb(m)=get_allmeasures(bxddb(m),testdb);
      fprintf('.');
    end
    
    % add normalized ap by b2l-strain mean
    if ~isempty(new_bxddb)
      if isfield(new_bxddb,'bregma2lambda')
        b2lmean=nanmean([new_bxddb(:).bregma2lambda]);
        for m=1:length(new_bxddb)
          new_bxddb(m).retinotopy_screen_center_ap_mb2l=...
            new_bxddb(m).retinotopy_screen_center_ap-0.449*b2lmean;
        end
      end
    end
    
    % add od response
    if ~isempty(new_bxddb)
      if isfield(new_bxddb,'od_contra')
        for m=1:length(new_bxddb)
          new_bxddb(m).od_response=new_bxddb(m).od_contra+...
            new_bxddb(m).od_ipsi;
        end    
      end
    end

    % add od pc response
    if ~isempty(new_bxddb)
      if isfield(new_bxddb,'od_contra')
        for m=1:length(new_bxddb)
          new_bxddb(m).od_pc_response=...
            [new_bxddb(m).od_contra new_bxddb(m).od_ipsi]* ...
            [2.5 ; 1]/sqrt(2.5^2 +1^2);
        end    
      end
    end

    % add od pc od
    if ~isempty(new_bxddb)
      if isfield(new_bxddb,'od_contra')
        for m=1:length(new_bxddb)
          new_bxddb(m).od_pc_od=...
            [new_bxddb(m).od_contra new_bxddb(m).od_ipsi]* ...
            [-1;2.5 ]/sqrt(2.5^2 +1^2);
        end    
      end
    end

    
    
    % add normalized b2l by weight from strain mean weight
    if ~isempty(new_bxddb)
      if isfield(new_bxddb,'bregma2lambda') &  isfield(new_bxddb,'weight')
        weightmean=nanmean([new_bxddb(:).weight]);
        for m=1:length(new_bxddb)
          new_bxddb(m).bregma2lambda_weight_corrected=...
            new_bxddb(m).bregma2lambda - 0.042066* (new_bxddb(m).weight-weightmean);
        end
      end
    end

    
  else
    new_bxddb=[];
  end
  fprintf('\n');
  bxddb_per_strain{end+1}=new_bxddb;
end

bxddb=[bxddb_per_strain{:}];


save 'all_bxd_data.mat' bxddb bxddb_per_strain
