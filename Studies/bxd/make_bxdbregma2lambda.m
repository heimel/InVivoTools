% make_bxdbregma2lambda
cd(bxddatadir);

labels=[' ']; % ['yND';'yMD'];
strains=neurobsik_strains;

%strains={strains{2:10}};
n_strains=length(strains);
cluster_strains=1;

!rm results.csv
types={'(type=control 1 month*|type=MD 7d from p28*)'};
[r_n,p_n]=make_popgraph(strains,types,'none','bregma2lambda','',...
		    labels,'Distance of Bregma to Lambda (mm)',[2.5 6],...
			cluster_strains,[],0,[],[]);
save_figure('bregma2lambda_bxd');
!mv results.csv bregma2lambda_bxd.csv
her=heritability( r_n);
disp(['Heritability of bregma2lambda: ' num2str(her,2)]);


b2l=[];
for i=1:length(r_n)
  if isempty(r_n{i})
    b2l(i)=nan;
  else
    b2l(i)=nanmean(r_n{i});
  end
end


