function opt_cost = optfunct_clust(D,IDX,N_clusters)
CI=0;
for i=1:N_clusters
    CI(i)=(mean(D((IDX==i),i))/mean(D((IDX~=i),i)));
%     CI(i)=(mean(D((IDX==i),i))/mean(D(:,i)));
end
opt_cost=mean(CI);