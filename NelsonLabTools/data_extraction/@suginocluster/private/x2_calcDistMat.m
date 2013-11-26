function y = x2_calcDistMat(gcsp,nv)
% normalized square distance
NG = size(gcsp,2);
N  = size(gcsp,1);
noise = reshape(ones(N/4,1)*nv,N,1);

y = zeros(NG,NG);

for i=1:NG
	for j=(i+1):NG
		tmp =  mean( ( (gcsp(:,i)-gcsp(:,j)).^2)./noise ) ;
		y(i,j) = tmp;
		y(j,i) = y(i,j);
	end
end
