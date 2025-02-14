function [xcovar,zr,zm,br,bm]=spikecrosscorrelation_excit(sp1,sp2,tbins,t0,t1,stimtrigs,stimt0,stimt1,pretime)

% SPIKECROSSCORRELATION - Computes cross-correlation for spikedata objects
%
% [XCOVAR,ZR,BR]=SPIKECROSSCORRELATION_EXCIT(SP1,SP2,TIMEBINS,T0,T1,[STIMTRIGS, STIMT0, STIMT1])
%
%   Given spike data objects SP1 and SP2, this function computes the cross
% covariogram that can be explained due to correlation in excitability 
% over the time TIMEBINS (e.g., -0.100:0.001:0.100).
% TIMEBINS must be evenly spaced and increasing.
% Data from SP1 and SP2 from time T0 to T1 are used in the calculation.
% If STIMTRIGS, an array of beginning times of a particular stimulus, 
% is provided, then the cross-covariogram XCOVAR and the standard deviation
% about the covariogram XSTDDEV are returned.  BINS is a vector containing
% the center location of each bin defined by TIMEBINS and is provided for
% bar plotting convenience.  STIMT0 and STIMT1 define the timepoints around
% each entry of STIMTRIGS to calculate the XCOVAR.  EXPECT contains the
% expected correlation between the two neurons given their stimulus responses.
%
% Parameters ZR and BR correspond to those given in the second reference below.
%
% The cross-correlation and cross-covariogram are defined as in Brody CD,
% ``Correlations without synchrony'', Neural Comput. 1999 11:1537-51 and
% ``Disambiguating Different Covariation Types'', Neur. Comp. 1999 11:1527-1536.



spt1 = get_data(sp1,[t0 t1],2); spt2 = get_data(sp2,[t0 t1],2);
dt = tbins(2)-tbins(1);
xcortbins = [min(tbins)-dt/2 tbins+dt/2];
xcorbins = ceil(max(abs(tbins)-1e-15)/dt);  % MAXLAG
stimbins= stimt0:dt:stimt1;

[rast1,psth1,stddev1]=fastraster(sp1,stimtrigs,stimbins,2);
[rast2,psth2,stddev2]=fastraster(sp2,stimtrigs,stimbins,2); % psth is p

for i=1:length(stimtrigs),
	back1(i) = length(get_data(sp1,[stimtrigs(i)-pretime stimtrigs(i)]));
	back2(i) = length(get_data(sp2,[stimtrigs(i)-pretime stimtrigs(i)]));
end;

b1 = sum(back1)/(pretime*length(stimtrigs)); % mean background rates Hz
b2 = sum(back2)/(pretime*length(stimtrigs));

	% calc background gains
if b1~=0, br1 = back1./(b1*pretime); else, br1 = 0*back1; end;
if b2~=0, br2 = back2./(b2*pretime); else, br2 = 0*back2; end;

b1psth = b1*dt*ones(size(stimbins(1:end-1))); % make bins  p of spike in bin
b2psth = b2*dt*ones(size(stimbins(1:end-1)));

Z1 = psth1 - b1psth; Z2 = psth2 - b2psth; % now psth is like variable Z

for i=1:length(stimtrigs),
	%z1(i) = (sum(rast1(i,:))/dt-br1(i)*b1)/(sum(psth1));   % psth,Z are Hz
	%z2(i) = (sum(rast2(i,:))/dt-br2(i)*b2)/(sum(psth2));
	z1(i) = (sum(rast1(i,:))/dt-br1(i)*b1)/(sum(psth1)/dt); % psth,Z are probs
	z2(i) = (sum(rast2(i,:))/dt-br2(i)*b2)/(sum(psth2)/dt);
end;

zm = [Z1; Z2];

bm = [ b1 ; b2];

zr = [z1; z2];  br = [br1; br2];
c1 = cov(z1,z2); c2 = cov(z1,br2); c3 = cov(z2,br1); c4 = cov(br1,br2); % normalize by N-1
xcovar = c1(1,2)*xcorr(Z1,Z2,xcorbins)+c2(1,2)*xcorr(Z1,b2psth,xcorbins)+...
	c3(1,2)*xcorr(Z2,b1psth,xcorbins)+c4(1,2)*xcorr(b1psth,b2psth,xcorbins);
