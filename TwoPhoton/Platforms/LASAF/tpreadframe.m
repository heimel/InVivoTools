function [im,fname]=tpreadframe(dirname,fnameprefix,cycle,channel,frame)
%TPREADFRAME
%  read frame from multitiff
%
% 2008, Alexander Heimel
%

fname=[dirname filesep fnameprefix '_t' sprintf('%.4d',frame-1) '.tif'];
fname2=[dirname filesep fnameprefix '_t' sprintf('%.4d',frame-1) '.tiff'];
try,
	im=sum(imread(fname),3);
catch,
	im=sum(imread(fname2),3);
end;
