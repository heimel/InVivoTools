function tinf = tiffinfo_parse_imagej(tinf)
%TIFFINFO_PARSE_IMAGEJ used by tiffinfo for imagej metadata
%
% TINF = TIFFINFO_PARSE_IMAGEJ( TINF )
%
% 2012, Alexander Heimel
%

% NumberOfChannels
% NumberOfFrames
% x_step
% x_unit
% y_step
% y_unit
% if more than 1 frame
%   third_axis_name
%   third_axis_unit
%   if third_axis_name is t
%     frame_period
%     frame_timestamp
%   if third_axis_name is z
%     z_step
%     z_unit
%     z

if isfield(tinf(1).ParsedImageDescription,'channels')
    tinf(1).NumberOfChannels = tinf(1).ParsedImageDescription.channels;
else
    tinf(1).NumberOfChannels = 1;
end

if isfield(tinf(1).ParsedImageDescription,'images')
    tinf(1).NumberOfFrames = tinf(1).ParsedImageDescription.images / tinf(1).NumberOfChannels;
elseif isfield(tinf(1).ParsedImageDescription,'frames')
    tinf(1).NumberOfFrames = tinf(1).ParsedImageDescription.frames / tinf(1).NumberOfChannels;
else
    tinf(1).NumberOfFrames = 1;
end

    



if isfield(tinf,'XResolution') &&  ~isempty(tinf(1).XResolution)
    tinf(1).x_step = 1/tinf(1).XResolution;
    tinf(1).x_unit = tinf(1).ParsedImageDescription.unit;
else
    tinf(1).x_step = 1;
    tinf(1).x_unit = 'pixel';
end

if isfield(tinf,'YResolution') &&  ~isempty(tinf(1).YResolution)
    tinf(1).y_step = 1/tinf(1).YResolution;
    tinf(1).y_unit = tinf(1).ParsedImageDescription.unit;
else
    tinf(1).y_step = 1;
    tinf(1).y_unit = 'pixel';
end

if isfield(tinf(1).ParsedImageDescription,'frames')
    tinf(1).third_axis_name = 't' ;
else    
    tinf(1).third_axis_name = 'z' ;
end
if isfield(tinf(1).ParsedImageDescription,'unit')
    tinf(1).third_axis_unit = tinf(1).ParsedImageDescription.unit;
else
    tinf(1).third_axis_unit = '';
end
if isfield(tinf(1).ParsedImageDescription,'spacing')
    tinf(1).z_step = tinf(1).ParsedImageDescription.spacing;
    tinf(1).z_unit = tinf(1).ParsedImageDescription.unit;
else
    tinf(1).z_step = 1;
    tinf(1).z_step = 'slice';
end
tinf(1).z = tinf(1).z_step * 1:tinf(1).NumberOfFrames;
