function fea = cl_extractFeature(csp,spikeloc,datadir)
% fea = extractFeature(csp,win)

L = size(csp,1)/4;
N = size(csp,2);

wind=2;

fea = zeros(N,4);
for i=1:N
	tmp = reshape(csp(:,i), L, 4);
% 	tmp = tmp - ones(L,1)*mean(tmp);
% 	fea(i,:) = (ma>mi).*(ma) + (ma<=mi).*(-mi);
% 	fea(i,:) = trapz(tmp);
	if (datadir==2)|(datadir==0),
           [ma,mai] = max(tmp(spikeloc-wind:spikeloc+wind,:));
        elseif (datadir==1),
           [ma,mai] = min(tmp(spikeloc-wind:spikeloc+wind,:));
        else, error('datadir must be 0, 1, or 2.');
        end;
	fea(i,:) = ma;
end
