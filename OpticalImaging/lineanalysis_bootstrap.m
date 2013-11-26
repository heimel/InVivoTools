function [pvals] = lineanalysis_bootstrap(line1obs,line2obs,numsims)

% LINEANALYSIS_BOOTSTRAP Statistical analysis of line image overlap
%
%  PVALS=LINEANALYSIS_BOOTSTRAP(OBS1DATA,OBS2DATA,NUMSIMS)
%
% For each point along a line, returns the PVAL that the data can be
% associated correctly with each distribution.  The N observations for
% each point are given in OBS1DATA and OBS2DATA.  NUMSIMS is the number
% of simulations to perform with the bootstrap algorithm to estimate PVALS.

N = size(line1obs,2);
ncorr = zeros(size(line1obs,1),1);
mn1 = mean(line1obs')';
mn2 = mean(line2obs')';

for j=1:numsims,
	newdat1 = line1obs(:,ceil(rand(N,1)*N));
	mn = mean(newdat1')';
	ncorr = ncorr + (abs(mn-mn1)<abs(mn-mn2));

	newdat2 = line2obs(:,ceil(rand(N,1)*N));
	mn = mean(newdat2')';
	ncorr = ncorr + (abs(mn-mn1)>abs(mn-mn2));
end;

pvals=ncorr/(2*numsims);
