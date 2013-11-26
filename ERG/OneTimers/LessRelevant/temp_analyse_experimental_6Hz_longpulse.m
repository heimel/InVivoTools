global blockRunData;

datin = blockRunData.data;
clear datuit;

period = 1660;
for j = 1:size(datin,1)
  datuit(j,:) = zeros(1,period);
  for i = 10:50
%      datuit(j,:) = datuit(j,:) + datin(j,1+(i-1)*1660:i*1660);
      datuit(j,:) = datuit(j,:) + datin(j,1+(i-1)*period:i*period);
  end
  datuit(j,:) = datuit(j,:) / 30;
end  
plot(min(datuit')-mean(datuit(:,1:200),2)');  

%plot(datuit');  
%plot(datuit(:,800));  