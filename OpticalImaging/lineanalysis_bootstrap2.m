function [classvals] = lineanalysis_bootstrap(line1obs,line2obs,numsims)

% LINEANALYSIS_BOOTSTRAP Statistical analysis of line image overlap
%
%  CLASSVALS=LINEANALYSIS_BOOTSTRAP(OBS1DATA,OBS2DATA,NUMSIMS)
%
% For each point along a line, returns the CLASSVAL that the mean value that
% a simulated experiment associates the point with the first (+1) or second
% (-1) stimulus.  The N observations for each point are given in OBS1DATA and
% OBS2DATA.  NUMSIMS is the number of simulations to perform with the
% bootstrap algorithm to estimate CLASSVALS. This algorithm differs from the
% original in that a winner-take-all is performed to classify pixels as
% belonging to stim1 or stim2.

N = size(line1obs,2);
ncorr = zeros(size(line1obs,1),1);
mn1 = mean(line1obs')';
mn2 = mean(line2obs')';

for j=1:numsims,
	newdat1 = line1obs(:,ceil(rand(N,1)*N));
	newdat2 = line2obs(:,ceil(rand(N,1)*N));
	mn1 = mean(newdat1')';
	mn2 = mean(newdat2')';
	nncorr = -1*ones(size(mn1));
	nncorr(find(mn1>mn2)) = 1;
	ncorr = ncorr + nncorr;
end;

classvals=ncorr/(numsims);
