function E = CSOcompute(X,contdist)
E = zeros(size(X));
E(1,:) = zeros(1,size(X,2));
E(size(X,1),:) = zeros(1,size(X,2));
% j=1;
for i=2:size(X,1)-1
E(i,:)=(2*X(i,:)-X(i-1,:)-X(i+1,:))/(contdist^2);
% E(j,:)=(2*X(i,:)-X(i-1,:)-X(i+1,:))/((contdist^2);
% E(j+1,:)=(2*X(i,:)-X(i-1,:)-X(i+1,:))/(0.75*(contdist^2));
% j=j+2;
end;