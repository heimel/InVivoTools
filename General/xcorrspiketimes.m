% XCORRSPIKETIMES - Computes cross-correlation between two spike trains
%
%  The calling syntax is:
%
%   [XCORR] = XCORRSPIKETIMES(X1,X2,T0,T1,TIMERES)
%
%   X1 and X2 are spike times, and TIMEBINS is a list of time bins 
%   over which to compute the cross-correlation
%   (e.g., -0.100:0.001:0.100 + 0.0005).  The 't'th entry in XCORR
%   is the number of spikes in X2 that fall between TIMEBINS(t) and
%	TIMEBINS(t+1), so XCORR has size 1xLENGTH(TIMEBINS)-1.
%	X1,X2, and TIMEBINS are expected to be sorted and in increasing
%	order.
%   
%   See also: XCORR

