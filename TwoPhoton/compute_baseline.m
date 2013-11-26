function baseline = compute_baseline(basetimes, baselinemethod, isidata, isitimes, isidatam, isitimesm, blankdata, blanktimes, blankdatam, blanktimesm)

%  COMPUTE_BASELINE - Compute baseline F for dF/F for two-photon data
%
%   BASELINE = COMPUTE_BASELINE(BASETIMES, BASELINEMETHOD, ...
%                ISIDATA, ISITIMES, ISIDATAM, ISITIMESM, ...
%              BLANKDATA, BLANKTIMES, BLANKDATAM, BLANKTIMESM)
%
%  Computes baseline values given recording samples of interstimulus
%  intervals and "blank" stimuli.  ISIDATAM and ISITIMESM are
%  mean values for the entire ISI interval and BLANKM and BLANKTIMESM
%  are mean values for the entire blank interval.  ISIDATA, ISITIMES,
%  BLANKDATA, and BLANKTIMES are individual observations.
%
%  The baseline is computed for times BASETIMES and returned in BASELINE.
%
%  BASELINEMETHOD determines the algorithm:
%    0:  use nearest ISI data
%    1:  use nearest blank stimulus
%    2:  use average over a 10s window of ISI and blank data


baseline = [];

for i=1:length(basetimes),
	switch baselinemethod,
		case 0,
			nearest = findclosest(isitimesm,basetimes(i));
			baseline(i) = isidatam(nearest);
		case 1,
			nearest = findclosest(blanktimesm,basetimes(i));
			baseline(i) = blankdatam(nearest);
		case 2,
			inds_isi = find(isitimes>basetimes(i)-5&isitimes<basetimes(i)+5);
			inds_blank = find(blanktimes>basetimes(i)-5&blanktimes<basetimes(i)+5);
			baseline(i) = nanmean([ isidata(inds_isi) ; blankdata(inds_blank)]);
	end;
end;
