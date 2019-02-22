function monitor = monitor_configuration(record)
%MONITOR_CONFIGURATION returns struct with monitor configuration info
%
%  MONITOR = MONITOR_CONFIGURATION( RECORD )
%
% 2016, Alexander Heimel

if nargin<1 || isempty(record)
    switch host
        case {'wall-e','stim3d'}
            record.setup = 'olympus-0603301';
        case 'robbie' 
            record.setup = 'antigua';
        otherwise
            record.setup = host;
    end
end

monitor.size_cm = [51 29];
monitor.size_pxl = [1920 1080];
monitor.slant_deg = 0;
monitor.center_rel2nose_cm = [0 0 15];
monitor.tilt_deg = 0;
% first get monitor info
switch lower(record.setup)
    case {'olympus-0603301','wall-e'} %dani's settings measured 5-4-2016, don't change
        monitor.size_cm = [51 29];
        monitor.size_pxl = [1920 1080];
        monitor.slant_deg = 45; % left towards mouse
        monitor.center_rel2nose_cm = [10 0 7];
        monitor.tilt_deg = 20;
    case 'antigua'
        monitor.size_cm = [60 42];
        monitor.size_pxl = [1152 864];
        monitor.slant_deg = 0;
        monitor.center_rel2nose_cm = [0 0.1*monitor.size_cm(2) 17.5];
    otherwise
        logmsg('Cannot recognize monitor settings. Defaulting');
end