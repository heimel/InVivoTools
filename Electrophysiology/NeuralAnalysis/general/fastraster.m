function [rast,psth,stddev] = fastraster(spikedata, triggers, bins, norm)

%  FASTRASTER - Computes a raster and psth from spike data
% 
%  [RAST,PSTH,STDDEV] = FASTRASTER(SPIKEDATA, TRIGGERS, BINS, [normalization])
%
%  Computes a raster, psth, and standard deviation for SPIKEDATA object
%  SPIKEDATA, triggered on times listed in TRIGGERS, and using bins
%  BINS, where BINS are relative to the trigger.  Each row of RAST contains
%  the number of spikes per bin for each response, and PSTH is one row,
%  containing the total number of spikes for all triggers.
%
%  The psth may be optionally normalized, with 0 indicating not at all (the
%  default), 1 indicating division by number of trials and bin interval, and
%  2 indicating division by number of trials only.  The standard deviation is
%  always normalized by the number of trials.


bmn = min(bins); bmx = max(bins);
mn = min(triggers); mx = max(triggers);
sp = get_data(spikedata,[mn mx],2);

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
