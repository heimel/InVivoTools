function tinf = tiffinfo_parse_scanimage(tinf)
%TIFFINFO_PARSE_SCANIMAGE used by tiffinfo for Scanimage tiffs
%
% TINF = TIFFINFO_PARSE_SCANIMAGE( TINF )
%   adds the following fields to TINF struct:
%       NumberOfChannels
%       NumberOfFrames
%         third_axis_name
%         third_axis_unit
%       if third_axis_name is t
%         frame_period
%
% 2013, Alexander Heimel
%
%

disp('TIFFINFO_PARSE_SCANIMAGE: Only rudimentary implementation');

tinf(1).NumberOfChannels = tinf(1).ParsedImageDescription.state_acq_numberOfChannelsSave;
tinf(1).NumberOfFrames = tinf(1).ParsedImageDescription.state_acq_numberOfZSlices;
tinf(1).third_axis_name = 'z';
tinf(1).third_axis_unit = '';

tinf(1).x_step = 1;
tinf(1).x_unit = 'pixel';

tinf(1).y_step = 1;
tinf(1).y_unit = 'pixel';

tinf(1).z_step = 1;
tinf(1).z_step = 'slice';