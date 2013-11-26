function [osi,dsi] = compute_orientation_selectivity_index( angles, rates )
% COMPUTE_ORIENTATION_SELECTIVITY_INDEX returns orientation and direction selectivity index
%
%     [OSI,DSI] = COMPUTE_ORIENTATION_SELECTIVITY_INDEX( ANGLES, RATES )
%
%     Takes ANGLES in degrees
%
%     Orientation preference and selectivity was calculated by vector
%     averaging (Swindale et al., 1987). The orientation selectivity index 
%     OSI) was calculated as the magnitude of the vector average divided 
%     by the sum of all responses: 
%     OSI = ((?R(?i)sin(2?i))^2 + (?R(?i)cos(2?i))^2)^(1/2)/?R(?i),
%     where ?i is the orientation of each stimulus and R(?i) is the 
%     response to that stimulus (Ringach et al., 2002 and Wörgötter and 
%     Eysel, 1987; Note: OSI = 1 – circular variance)"
%     and for the suppression index
%
% 2013, Daniela Camillo

osi = [];
dsi = [];

angles = angles(:);
rates = rates(:);

osi  = sqrt((rates'*sin(2*(angles/360*2*pi)))^2+(rates'*cos(2*(angles/360*2*pi)))^2) / sum(rates);
dsi  = sqrt((rates'*sin((angles/360*2*pi)))^2+(rates'*cos((angles/360*2*pi)))^2) / sum(rates);
