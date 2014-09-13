function [pts,ang,q,s] = plottract(startpt, endpt, tractpts)

%  PLOTTRACT - Guides plotting of electrode tract
%  
%  [PTS,ANG,Q] = PLOTTRACT(STARTPT, ENDPT, TRACTPTS)
%
%  Gives coordinates for plotting electrode tract points on a
%  histological photograph of brain tissue.  Accepts the starting point
%  and ending points in the photograph's coordinates, and the points along
%  the tract in the electrode manipulator's coordinates.  It returns in PTS
%  the points on the image that correspond to each point along the tract.
%  ANG is the angle of the penetration in the photograph's coordinate frame.
%  Q is the rotation matrix used; s is the scale.
%
%  Note:  This assumes that the y axis is reversed, as it is in most images.

ang = atan2((startpt(2)-endpt(2)),(endpt(1)-startpt(1))); %*180/pi;
s = dist(startpt,endpt)/(tractpts(end)-tractpts(1));
q = [ cos(ang) -sin(ang) ; sin(ang) cos(ang) ];

pts = [];
for i=1:length(tractpts),
	pts = [pts;startpt+[tractpts(i)-tractpts(1) 0]*q*s];
end;
ang = ang * 180/pi;
function d = dist(b,a)
d = sqrt(sum((b-a).^2));
