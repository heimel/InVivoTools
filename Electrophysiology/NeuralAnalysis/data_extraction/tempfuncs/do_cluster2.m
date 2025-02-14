function ci = do_cluster2(N)

global K;

ci = zeros(N,1);

for i=1:N
	ci(i) = find_peak2(K(i,1),K(i,2),K(i,3),K(i,4));
end
