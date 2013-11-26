function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file
%
%
% PARAMS. = 
%  params.Main.Total_cycles  (total number of cycles)
%  params.Main.Scanline_period__us_  (scanline period, in us)
%  params.Main.Dwell_time__us_  (pixel dwell time, in us)
%  params.Main.Frame_period__us_  (frame period, in us)
%  params.Main.Lines_per_frame (lines per frame)
%  params.Main.Pixels_per_line  (number of pixels per line)
%  params.Image_TimeStamp__us_  (list of all frame timestamps)
%  params.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%   params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1E-6
%
% PrairieView version
% 
% Steve VanHooser, Alexander Heimel
%

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile)
	pcfile = dir([tpdirname filesep '*.xml']);
end;
if isempty(pcfile),
	error(['Could not find parameters in directory ' tpdirname '.']);
end;
pcfile = pcfile(end).name;
params = readprairieconfig([tpdirname filesep pcfile]);
 
params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1e-6; %change to s
