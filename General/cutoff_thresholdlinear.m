function [cutoff, rc, offset]=cutoff_thresholdlinear(x,y)
%CUTOFF_THRESHOLDLINEAR returns thresholdlinear interection with x-axis
%
%  [CUTOFF, RC, OFFSET]=CUTOFF_THRESHOLDLINEAR(X,Y)
%
% 2005, Alexander Heimel
%
  
  [rc,offset]=fit_thresholdlinear(x,y);
  
  cutoff= -offset/rc;
