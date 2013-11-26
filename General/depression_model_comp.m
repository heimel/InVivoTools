function syncurrs = depression_model_comp(spiketimes,a0,f,ftau,d,dtau)

%  DEPRESSION_MODEL_COMP-Computes synaptic currents for Varela depression model
%
%    SYNCURRS = DEPRESSION_MODEL_COMP(SPIKETIMES,A0,F,FTAU,D,DTAU)
%
%  Computes synaptic currents for a facilitating and/or depressing synapse.
%  Presynaptic spike times are given in SPIKETIMES, and the unfacilitated,
%  undepressed amplitude of the synapse is A0.
%
%  Synaptic currents are modeled as A = A0*F1*...*FN*D1*...*DN,
%    where F1...FN are facilitating factors and D1...DN are depressing
%  factors.
%
%  After each presynaptic spike, Fi -> Fi + fi, where fi is a positive
%  number, and Fi decays back to 1 with time constant fitau.
%  Input argument F is an array containing fi, and the length of F determines
%  the number of facilitating factors (use empty for none).  FTAU is an array
%  of the same length of F and contains the time constants fitau.
%
%  After each presynaptic spike, Di -> Di * di, where 0 < di <= 1, and Di
%  decays back to 1 with time constant ditau.  Input argument D is an array
%  containing di, and the length of D determines the number of facilitating
%  factors (use empty for none).  DTAU is an array of the same length of D
%  and contains the time constants ditau.
%
%  See Varela,Sen,Gibson,Fost,Abbott,and Nelson,J.Neurosci.17:7926-40,1997.

syncurrs = zeros(size(spiketimes));

syncurrs(1) = a0;
dt = Inf; fi = 1+f; di = d;

for t=2:length(spiketimes),
	dt = spiketimes(t)-spiketimes(t-1);
	syncurrs(t) = a0;
	if ~isempty(f),
		fi_before = 1+(fi-1).*exp(-dt./ftau);
		syncurrs(t)=syncurrs(t)*prod(fi_before);
		fi = fi_before + f;
	end;
	if ~isempty(d),
		di_before = 1+(di-1).*exp(-dt./dtau);
		syncurrs(t)=syncurrs(t)*prod(di_before);
		di = di_before .* d;
	end;
end;
