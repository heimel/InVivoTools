function adv = phase_advance(angles)
%  PHASE_ADVANCE - Computes phase advance from a list of angles
% 
%   ADV = PHASE_ADVANCE(ANGLES)
%
%  Computes the advance in phase from each angle, assuming an angle does not
%  advance more than pi.

if isempty(angles) adv = []; return; end;

adv(1) = 0;
for i=2:length(angles),
  dists=(angles(i)-angles(i-1))*[1 1 1] - 2*pi*[0 -1 1];
  [dummy,m] = min(abs(dists));
  adv(i) = dists(m(1));
end;
