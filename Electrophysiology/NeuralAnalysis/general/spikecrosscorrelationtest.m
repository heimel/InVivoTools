function [xcorrv,xcovar,xstddev,expect,psth1,psth2,r1,r2]=spikecrosscorrelationtest(sp1,sp2,tbins,t0,t1,stimtrigs,stimt0,stimt1)

% SPIKECROSSCORRELATION - Computes cross-correlation for spikedata objects
%
% [XCORR,XCOVAR,XSTDDEV,EXPECT]=SPIKECROSSCORRELATION(SP1,SP2,...
%     TIMEBINS,T0,T1,[STIMTRIGS, STIMT0, STIMT1])
%
%   Given spike data objects SP1 and SP2, this function computes the cross
% correlation XCORR over the time TIMEBINS (e.g., -0.100:0.001:0.100).
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
% The cross-correlation and cross-covariogram are defined as in Brody CD,
% ``Correlations without synchrony'', Neural Comput. 1999 11:1537-51.  

spt1 = sp1; spt2 = sp2; 
dt = tbins(2)-tbins(1);
xcortbins = [min(tbins)-dt/2 tbins+dt/2];
xcorrv=xcorrspiketimes(spt1,spt2,xcortbins);

if nargin>5,
	stimbins= stimt0:dt:stimt1;
	[r1,psth1,stddev1]=fastrasterimbed(sp1,stimtrigs,stimbins,2);
	[r2,psth2,stddev2]=fastrasterimbed(sp2,stimtrigs,stimbins,2);
	xcorbins = ceil(max(abs(tbins))/dt);
	expect = xcorr(psth1,psth2,xcorbins)';
	xcovar = zeros(length(xcortbins)-1,1);
	for i=1:length(stimtrigs),
		spt1=sp1(find(sp1>=stimbins(1)+stimtrigs(i)&sp1<stimbins(end)+stimtrigs(i)));
		spt2=sp2(find(sp2>=stimbins(1)+stimtrigs(i)&sp2<stimbins(end)+stimtrigs(i)));
		%spt1=sp1;
		%spt2=sp2;
		xcovar = xcovar+xcorrspiketimes(spt1,spt2,xcortbins);
	end;
	xcovar = xcovar/length(stimtrigs)-expect;
	xstddev=sqrt((xcorr(stddev1.*stddev1,stddev2.*stddev2,xcorbins)+...
		xcorr(psth1.*psth1,stddev2.*stddev2,xcorbins)+...
		xcorr(psth2.*psth2,stddev1.*stddev1,xcorbins))/length(stimtrigs));
end;

function [rast,psth,stddev] = fastrasterimbed(sp, triggers, bins, norm)

bmn = min(bins); bmx = max(bins);
mn = min(triggers); mx = max(triggers);
%sp = get_data(spikedata,[mn mx],2);

rast = zeros(length(triggers),length(bins));
psth = zeros(1,length(bins));

for i=1:length(triggers),
	r = histc(sp-triggers(i),bins);
	if isempty(r), r = zeros(1,length(bins)); end;  % catch zero condition
	rast(i,:) = r;
end;
rast = rast(:,1:end-1); % shorten since last bin makes no sense - see histc
psth = sum(rast);
stddev=std(rast);

% normalize psth
nrm = 1;
if nargin==4,
	switch norm,
	case 1, nrm = 1./(diff(bins)*length(triggers));
	case 2, nrm = 1/length(triggers);
	otherwise, nrm = 1;
	end;
end;

psth = psth*nrm;

