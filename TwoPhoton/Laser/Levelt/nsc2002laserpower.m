function frac = nsc2002laserpower( position )
%NSC2002LASERPOWER converts NSC200 position to fraction of laser power
%
%  FRAC = NSC2002LASERPOWER( POSITION )
%
% 2012, Alexander Heimel

minpos = laserpower2nsc200(0);
maxpos = laserpower2nsc200(1);

frac = (1+sin( (position -minpos)/(maxpos-minpos)*pi -pi/2))/2;
