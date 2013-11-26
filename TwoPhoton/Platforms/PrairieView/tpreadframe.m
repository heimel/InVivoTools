function [im,fname]=tpreadframe(dirname,fnameprefix,cycle,channel,frame)
%TPREADFRAME
%  read frame from single tiff
%
% 2008, Alexander Heimel
%
fname=fullfile(dirname,tpfilename(fnameprefix,cycle,channel,frame));
im=imread(fname);