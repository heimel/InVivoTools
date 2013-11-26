function b = floorfloor(x)

%  FLOORFLOOR  Rounds (i,i+1] to i
%
%  B = FLOORFLOOR(X)

C = floor(x); b = C-(C==ceil(x));
