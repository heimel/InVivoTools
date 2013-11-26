function [center, U, obj_fcn] = FCmeansClust(data, cluster_n)

data_n = size(data, 1); 
in_n = size(data, 2);   

options = [2;
    100;               
    1e-5;               
    1];                 

expo = options(1);          
max_iter = options(2);		
min_impro = options(3);		
display = options(4);		

obj_fcn = zeros(max_iter, 1);	
U = initfcm(cluster_n, data_n);     

for i = 1:max_iter,
	[U, center, obj_fcn(i)] = stepfcm(data, U, cluster_n, expo);
	if display, 
		fprintf('FCM:Iteration count = %d, obj. fcn = %f\n', i, obj_fcn(i));
	end

	if i > 1,
		if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro, 
            break;
        end,
	end
end

iter_n = i; 
obj_fcn(iter_n+1:max_iter) = [];

function U = initfcm(cluster_n, data_n)
U = rand(cluster_n, data_n);
col_sum = sum(U);
U = U./col_sum(ones(cluster_n, 1), :);

function [U_new, center, obj_fcn] = stepfcm(data, U, cluster_n, expo)
mf = U.^expo; 
center = mf*data./((ones(size(data, 2), 1)*sum(mf'))'); 
dist = distfcm(center, data);  
obj_fcn = sum(sum((dist.^2).*mf));  
tmp = dist.^(-2/(expo-1));     
U_new = tmp./(ones(cluster_n, 1)*sum(tmp)); 

function out = distfcm(center, data)
out = zeros(size(center, 1), size(data, 1));
for k = 1:size(center, 1), 
    out(k, :) = sqrt(sum(((data-ones(size(data,1),1)*center(k,:)).^2)',1));
end

