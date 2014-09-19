%
% ReceptiveFieldGlobals
%
% This script declares all of the receptive field mapping program.
%
% RFcurrentrect         -  The location on the screen where the RF stimuli are
%                             shown.
% RFparams              -  Current parameters associated with RF
%   ".state             -  State of the RF mapper; can be 0-off, 1-menu,
%                          2-mousefree stim, 3-mousestim
%   ".lastrect          -  Rectangle that was drawn in last (for blanking)
%   ".drawrect          -  Rectangle to draw in
%   ".stim              -  Stim being shown (0=field,1=blinker,2=lightbar)

global RFcurrentrect RFparams

