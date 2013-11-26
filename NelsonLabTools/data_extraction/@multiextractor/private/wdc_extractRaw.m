function fea = wdc_extractRaw(csp,spikeloc)

L = size(csp,1)/4;

spikelocs = spikeloc:L:spikeloc+L*3;

fea = csp(spikelocs,:);
