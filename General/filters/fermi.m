function ffilter = fermi(xdim, cutoff, trans_width)
% FERMI creates a 2D Fermi filter.
%   FFILTER = FERMI(XDIM,CUTOFF,TRANS_WIDTH) calculates a 2D
%     Fermi filter on a grid with dimensions XDIM * XDIM. 
%    The cutoff frequency is defined by CUTOFF and represents
%     the radius (in pixels) of the circular symmetric function   
%     at which the amplitude drops below 0.5
%    TRANS_WIDTH defines the width of the transition. 
%
%    Author: Wally Block, UW-Madison  02/23/01. 
%
%    Call: ffilter = fermi(xdim, cutoff, trans_width);

[X,Y] = meshgrid(-xdim/2:1:(xdim/2 -1),-xdim/2:1:(xdim/2 -1)); 
radius = [X.^2 + Y.^2].^0.5;
ffilter = 1./(1 + exp((radius -cutoff)/trans_width));
