function m=swf_pca(swf,n)
%SWF_PCA takes matrix [shape,spike#] and returns [shape wrt to pca,spike#] for the first N principal components

covswf=cov(swf');
[pca,latent,explained]=pcacov(covswf);
m=transpose(swf'*pca);
m=m(1:n,:);

