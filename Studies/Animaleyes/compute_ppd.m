function ppd=compute_ppd(length,distance,pixels)
%COMPUTE_PPD gives pixels per deree
%
%   PPD=COMPUTE_PPD(LENGTH,DISTANCE,PIXELS)
  ppd=pixels/(360*atan(length/distance)/(2*pi));
