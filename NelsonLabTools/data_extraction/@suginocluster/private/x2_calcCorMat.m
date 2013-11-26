function y = x2_calcCorMat(gcsp)
% normalized square distance
NG = size(gcsp,2);
N  = size(gcsp,1);
% noise = reshape(ones(N/4,1)*nv,N,1);
n = zeros(NG,1);
y = ones(NG,NG);

for i=1:NG
	n(i) = gcsp(:,i)'*gcsp(:,i);
end

for i=1:NG
	for j=(i+1):NG
		tmp =  gcsp(:,i)'*gcsp(:,j)/sqrt(n(i)*n(j));
		y(i,j) = tmp;
		y(j,i) = y(i,j);
	end
end
