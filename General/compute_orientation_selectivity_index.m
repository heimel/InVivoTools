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
%     OSI = ((Signa R(phi_i)sin(2phi_i))^2 + (Sigma R(phi_i)cos(2phi_i))^2)^(1/2)/Sigma R(phi_i),
%     where phi_i is the orientation of each stimulus and R(phi_i) is the 
%     response to that stimulus (Ringach et al., 2002 and Worgotter and 
%     Eysel, 1987; Note: OSI = 1 - circular variance)"
%     and for the suppression index
%
% 2013-2014, Daniela Camillo, Alexander Heimel
%
if nargin<2
    rates = [];
end
if isempty(rates)
    rates = ones(size(angles));
end

osi = [];
dsi = [];

angles = angles(:);
rates = rates(:);

% introduced thresholdlinear in August 2014?
rates = thresholdlinear(rates); 

if sum(rates)==0
    osi = nan;
    dsi = nan;
    return
end

osi  = sqrt((rates'*sin(2*(angles/360*2*pi)))^2+(rates'*cos(2*(angles/360*2*pi)))^2) / sum(rates);
dsi  = sqrt((rates'*sin((angles/360*2*pi)))^2+(rates'*cos((angles/360*2*pi)))^2) / sum(rates);

