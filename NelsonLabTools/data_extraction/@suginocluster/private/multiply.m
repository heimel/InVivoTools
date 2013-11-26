function csp2 = multiply(csp1,T);

csp2 = zeros(size(csp1));
L = size(csp1,1)/4;
for k=1:size(csp1,2)
	tmp = reshape(csp1(:,k),L,4);
	tmp = tmp*T;
	csp2(:,k) = reshape(tmp,4*L,1);
end
