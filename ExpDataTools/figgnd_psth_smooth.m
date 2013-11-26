function y = figgnd_psth_smooth( x )
%FIGGND_PSTH_SMOOTH wrapper function for PSTH smooting, used by GROUPGRAPH for figure-ground stimuli
%
%  FIGGND_PSTH_SMOOTH( X )
%
%  2010, Alexander Heimel
%

y = smooth( x, 20);