function [NumClusts,IDX,Cent] = optnum_clust(X)
max_clusts=5;
[COEFF, SCORE] = princomp(X);
fffsc=SCORE*COEFF;
opt_cost(1) = 1;
for i=2:max_clusts
    [IDX,Cent,sumD,D] = kmeans(fffsc,i);
    opt_cost(i) = optfunct_clust(D,IDX,i);
    if opt_cost(i)<=0.8*opt_cost(i-1)
        NumClusts=i-1;
        if i>2
        [IDX,Cent,sumD,D] = kmeans(X,i-1);
        else
        IDX=ones(size(X,1),1);Cent=mean(X,1);
        end
        return
    end
end

% [value_costf,NumClusts]=max(opt_cost);
IDX=ones(size(X,1),1);Cent=mean(X,1);
NumClusts=1;
return