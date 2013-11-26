function record = tp_get_distance_from_pia(record)
%TP_GET_DISTANCE_FROM_PIA computes the distance from pia for each roi]
%
% RECORD = TP_GET_DISTANCE_FROM_PIA( RECORD )
%
% 2013, Alexander Heimel
%

location = abs(str2num(record.location)); %#ok<ST2NM>
if length(location)~=3
    disp(['TP_GET_DISTANCE_FROM_PIA: Not three distances in location field. ' recordfilter(record)]);
 %   if ~strcmpi(record.experiment,'examples')
 %       errordlg(['Not three distances in location field. ' recordfilter(record)],'TP_get_distance_from_pia');
 %   end
    return
end

%   -----> x     A is origin
%  |
%  |   A---------C
%  v   |         |
%  y   |    B    |
%

dA = location(1);
dB = location(2);
dC = location(3);

params = tpreadconfig(record);

xB = 0.5 * params.Width * params.x_step;
yB = 0.5 * params.Width * params.y_step;
xC = params.Width * params.x_step;
yC = 0;

c = [dA dB dC xB yB xC yC];
x  = fminsearch(@(x) fiterror(x,c),[dA 0]);

r = x(1);
phi = x(2);
fdA = r;
fdB = abs( dA -  ( cos(phi)*xB - sin(phi)*yB) );
fdC = abs( dA -  ( cos(phi)*xC - sin(phi)*yC) );
disp(['TP_GET_DISTANCE_FROM_PIA: Measured locations ' mat2str(location,2) ...
    ', fitted locations ' mat2str([fdA fdB fdC],2)]);

for i = 1:length(record.ROIs.celllist);
    record.measures(i).distance_from_pia = abs( dA -  params.x_step* ...
        ( cos(phi)*median(record.ROIs.celllist(i).xi) - sin(phi)*median(record.ROIs.celllist(i).yi)));
end


function err = fiterror(x,params)
% params = [da,db,dc,xb,yb,xc,yc]
da = params(1);
db = params(2);
dc = params(3);
xb = params(4);
yb = params(5);
xc = params(6);
yc = params(7);
r = x(1);
phi = x(2);
fda = r;
fdb = abs( fda -  ( cos(phi)*xb - sin(phi)*yb) );
fdc = abs( fda -  ( cos(phi)*xc - sin(phi)*yc) );
err = (da-fda)^2 + (db-fdb)^2 + (dc-fdc)^2;


