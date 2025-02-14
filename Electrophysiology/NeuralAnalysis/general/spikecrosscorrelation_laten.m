function [xcorrv,xcovar,xstddev,expect,ts,psth1,psth2]=spikecrosscorrelation(sp1,sp2,tbins,t0,t1,stimtrigs,stimt0,stimt1)

% SPIKECROSSCORRELATION_LATEN - Computes cross-correlation for spikedata objects
%
% [XCORR,XCOVAR,XSTDDEV,EXPECT,TS]=SPIKECROSSCORRELATION_LATEN(SP1,SP2,...
%     TIMEBINS,T0,T1, STIMTRIGS, STIMT0, STIMT1)
%
%   Given spike data objects SP1 and SP2, this function computes the cross
% correlation XCORR over the time TIMEBINS (e.g., -0.100:0.001:0.100).
% TIMEBINS must be evenly spaced and increasing.
% Data from SP1 and SP2 from time T0 to T1 are used in the calculation.
% STIMTRIGS is an array of beginning times of a particular stimulus, 
% and the cross-covariogram XCOVAR and the standard deviation
% about the covariogram XSTDDEV are returned.  BINS is a vector containing
% the center location of each bin defined by TIMEBINS and is provided for
% bar plotting convenience.  STIMT0 and STIMT1 define the timepoints around
% each entry of STIMTRIGS to calculate the XCOVAR.  EXPECT contains the
% expected correlation between the two neurons given their stimulus responses.
% TS is the set of possible latency shifts that give the lowest correlation.
%
% This function is a companion of SPIKECROSSCORRELATION.  This version
% checks to see how much of the covariogram could possibly be explained
% by correlated latency shifts among the two neurons (see second article below).
%
% See also: SPIKECROSSCORRELATION
% 
% The cross-correlation and cross-covariogram are defined as in Brody CD,
% ``Correlations without synchrony'', Neural Comput 1999 11:1537-51.  
% The algorithm for computing latency contributions is given in
% ``Disambiguating different covariation types'', Neur Comp 1999 11:1527-1535

maxiter = 10;

dt = tbins(2)-tbins(1);
xcortbins = [min(tbins)-dt/2 tbins+dt/2];
xcorbins = ceil(max(abs(tbins)-1e-15)/dt);  % MAXLAG
stimbins= stimt0:dt:stimt1;

tsvals = -0.1:0.010:0.1;

 % randomly choose starting values to search in
ts = tsvals(ceil(mod(rand(length(stimtrigs),1)*length(tsvals),length(tsvals))));

if ~eqlen(size(ts),size(stimtrigs)), ts = ts'; end;

 % search for set of ts that give smallest covariogram
 % do this iteratively starting from random ts, then
 %   vary ts(i) of each trial i to find local min
 % repeat a maximum of ten times or until global error stops getting smaller

lasterr = Inf; currerr = realmax; iter = 0;

xcovar = zeros(length(xcortbins)-1,1); 
spt1_ = []; spt2_ = [];
for ii=1:length(stimtrigs),
	spt1=get_data(sp1,[stimbins(1) stimbins(end)]+stimtrigs(ii),2);
	spt2=get_data(sp2,[stimbins(1) stimbins(end)]+stimtrigs(ii),2);
	spt1_ = [spt1_ spt1]; spt2_ = [spt2_ spt2];
	xcovar = xcovar+xcorrspiketimes(spt1,spt2,xcortbins);
end;
xcorrv = xcovar;
 
while (iter<maxiter)&(currerr<lasterr),
	for i=1:length(stimtrigs),
		i,
	  bestj = 1; lowerr = Inf;
	  for j=1:length(tsvals),
		ts(i) = tsvals(j);
		[dum,psth1,stddev1]=fastraster(sp1,stimtrigs+ts,stimbins,2);
		[dum,psth2,stddev2]=fastraster(sp2,stimtrigs+ts,stimbins,2);
		expect = xcorr(psth1,psth2,xcorbins)'; 
		xcovar = xcorrv/length(stimtrigs)-expect;
		theerr = sum(abs(xcovar));
		%disp(['i= ' int2str(i) ', j=' int2str(j) ', currerr is ' mat2str(theerr) ', lowerr is ' mat2str(lowerr) '.']);
		if theerr<lowerr, bestj = j; lowerr = theerr; end;
  	  end;
	  ts(i) = tsvals(bestj);
	end;
	lasterr = currerr; currerr = lowerr;
	iter = iter+1, currerr,
end;


 % recompute with last parameters

[dum,psth1,stddev1]=fastraster(sp1,stimtrigs+ts,stimbins,1);
[dum,psth2,stddev2]=fastraster(sp2,stimtrigs+ts,stimbins,1);
expect = xcorr(psth1,psth2,xcorbins)'; 
xcovar = xcorrv/length(stimtrigs)-expect;
xstddev=sqrt((xcorr(stddev1.*stddev1,stddev2.*stddev2,xcorbins)+...
	xcorr(psth1.*psth1,stddev2.*stddev2,xcorbins)+...
	xcorr(psth2.*psth2,stddev1.*stddev1,xcorbins))/length(stimtrigs));
