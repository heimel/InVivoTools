function plotimagemap(map,minpix,maxpix,mintouse,maxtouse)

% PLOTIMAGEMAP  - Plots an intrinsic image map scaled between two pixel values
%
%  PLOTIMAGEMAP(MAP,MINPIX,MAXPIX,[MINTOUSE MAXTOUSE])
%
%  Scales data between MINPIX and MAXPIX before plotting it using the IMAGE
%  function.  If MINTOUSE and MAXTOUSE are provided, data are first thresholded
%  below by MINTOUSE and above by MAXTOUSE before scaling.

if ~strcmp(class(map),'double'), map = double(map); end;
if nargin>3,
	map(find(map<mintouse))=mintouse;
	map(find(map>maxtouse))=maxtouse;
end;
newmap = map-min(min(map));
newmap = newmap./max(max(newmap));
newmap = minpix + (maxpix-minpix)*newmap;
image(newmap);
