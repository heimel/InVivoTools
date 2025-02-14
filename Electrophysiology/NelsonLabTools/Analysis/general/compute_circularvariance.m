function cv = compute_circularvariance( angles, rates )

% COMPUTE_CIRCULARVARIANCE
%     CV = COMPUTE_CIRCULARVARIANCE( ANGLES, RATES )
%
%     Takes ANGLES in degrees
%
% CV = 1 - |R|
% R = (RATES * EXP(2I*ANGLES)') / SUM(RATES)
%
% See Rinach et al. J.Neurosci. 2002 22:5639-5651

if nargin<2
    rates = [];
end
if isempty(rates)
    rates = ones(size(angles));
end

angles = angles/360*2*pi;
r = (rates * exp(2i*angles)') / sum(rates);
cv = 1-abs(r);
cv=round(100*cv)/100;