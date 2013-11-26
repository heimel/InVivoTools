%Shuffles around a dataset and returns the shuffeled set. (shuffles columns)
function dsout = erg_analysis_shuffle(dsin)
  dsout = dsin;
  for i = (1:size(dsout,2))
    a = round(rand*(length(dsout)-1))+1;
    b = round(rand*(length(dsout)-1))+1;
    dummy = dsout(:,a);
    dsout(:,a) = dsout(:,b);
    dsout(:,b) = dummy;
  end
end