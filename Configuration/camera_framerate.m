function rate=camera_framerate( system, header)
%CAMERA_FRAMERATE returns rate of specific camera of Optical Imaging setup
%
%  Needs to be manually changed if a different camera is used
%
% 2005-2019 Alexander Heimel
%

if nargin==0
    system = host;
end

if nargin<2
    header = [];
end

if ~isempty(header)
    switch header(929)
        case 15
            rate = 1/0.04032972;  % approx 25 Hz % old vdaq camera
        case 30
            rate = 50; % Hz
        case 10 % Ninad
            rate = 100; % Hz
        otherwise
            warning('CAMERA_FRAMERATE:UNKNOWN','CAMERA_FRAMERATE: Unknown imaging system. Defaulting to daneel');
            warning('off','CAMERA_FRAMERATE:UNKNOWN');
            rate=1/0.04032972;  % Hz % old vdaq camera
    end
else
    switch system
        case 'andrew'
            rate = 50; %Hz new vdaq camera
        case 'daneel'
            rate = 1/0.04032972;  % Hz % old vdaq camera
        case 'ninad'
            rate = 100; % Hz
        otherwise
            warning('CAMERA_FRAMERATE:UNKNOWN','CAMERA_FRAMERATE: Unknown imaging system. Defaulting to daneel');
            warning('off','CAMERA_FRAMERATE:UNKNOWN');
            rate = 1/0.04032972;  % Hz % old vdaq camera
    end
end
