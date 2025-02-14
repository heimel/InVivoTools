function cls = clusterall(cellcl,fea)
sz = length(cellcl);
cls = zeros(size(fea,1),sz);
size(cls),
for i=1:sz,
  cls(:,i) = wdc_findptsincluster(fea,cellcl{i});
end;

