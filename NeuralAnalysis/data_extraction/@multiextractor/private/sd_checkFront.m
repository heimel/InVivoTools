function [st1,typ1] = sd_checkFront(ex,e,st,typ,th,ns,dt,skip,merge)

pnwin1 = ceil(300e-6/dt);
pnwin2 = ceil(2500e-6/dt);
npwin = ceil(600e-6/dt);
npwin2 = ceil(1500e-6/dt);
ratio  = 0.3;
ratio2 = 0.5;

st1 = st;
typ1 = typ;

% if typ == 2	% -
% 	win = pnwin2;
% 	typ0 = 3;
% 	s0 = 1;
% elseif
if typ == 1	% +
	win = npwin;
	typ0 = 4;
	s0 = -1;
elseif typ == 3 % +-
	win = npwin;
	typ0 = 5;
	s0 = -1;
else
	return;
end

% minor bug - this will select any peak between from and st,
% but we really only want peaks within 'merge' of st; any
% peak closer than 'skip' should not have been found before
% anyway, so we ignore that case
% fixed 2001-08-17
from = st - win;
ppos = peakPos2(e(from:st-3),th,skip,merge);
if isempty(ppos)|((st-(ppos(end)+from-1))>merge)
	return;
end

pp = ppos(end)+from-1;
s = sd_calcSign(ex,pp,skip,ns);
if s == s0
	st1 = pp;
	typ1 = typ0;
end
