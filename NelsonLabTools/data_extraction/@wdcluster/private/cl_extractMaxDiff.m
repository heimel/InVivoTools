function fea = cl_extractFeature(sc,csp,dt)
% fea = extractFeature(csp,win)
% win : search window for other peaks
win = ceil(sc.SCparams.spikewin/dt);

L = size(csp,1)/4;
N = size(csp,2);

fea = zeros(N,4);
for i=1:N
	tmp = reshape(csp(:,i), L, 4);
% 	tmp = tmp - ones(L,1)*mean(tmp);
% 	fea(i,:) = (ma>mi).*(ma) + (ma<=mi).*(-mi);
% 	fea(i,:) = trapz(tmp);
	[ma,mai] = max(tmp);
	[mi,mii] = min(tmp);

	[mach,machi] = max(ma);
	mapos = mai(machi);
	[mich,michi] = min(mi);
	mipos = mii(michi);
	st = max(1, mapos-win);	ed = min(L, mapos+win);
	[ma,mai] = max(tmp(st:ed,:));
	mai = mai + st -1;
	st = max(1, mipos-win);	ed = min(L, mipos+win);
	[mi,mii] = min(tmp(st:ed,:));
	mii = mii + st -1;
	
	fea(i,:) = (mai>mii).*(ma-mi) + (mai<=mii).*(mi-ma);
end
