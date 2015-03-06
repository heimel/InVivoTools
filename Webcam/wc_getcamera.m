function [camid,device] = wc_getcamera
%WEBCAM_GETCAMERA
%
% [CAMID,DEVICE] = WEBCAM_GETCAMERA
%
% 2014, Azedeh Tafreshiha, Alexander Heimel

devices = Screen('VideoCaptureDevices');
camera_found = false;
for d=1:length(devices)
    if strcmp(devices(d).Device, '/dev/video0') && strcmp(devices(d).ClassName,'Video4Linux2')
        camera_found = true;
        break
    end
    if strcmp(devices(d).DeviceName,'Laptop_Integrated_Webcam_HD') && strcmp(devices(d).ClassName,'Video4Linux2')
        camera_found = true;
        break
    end
end
if ~camera_found
    logmsg('Not found camera that I recognized');
    if isempty(devices)
        errormsg('No camera found.');
        return
    end
    d = 1;
end

camid = devices(d).DeviceIndex;
device = devices(d);