function fea = cl_extractRaw(sc,csp,dt,spikeloc)
% fea = extractFeature(csp,win)
% win : search window for other peaks

L = size(csp,1)/4;
%N = size(csp,2);

spikelocs = spikeloc:L:spikeloc+L*3;

fea = csp(spikelocs,:);
