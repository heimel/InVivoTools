function [fmiddle,ext] = tpfilename_setupdependent( record, frame, channel )
%DEZEEUW/TPFILENAME_SETUPDEPENDENT
%
% [MIDDLE,EXT] = TPFILENAME_SETUPDEPENDENT( RECORD )
%     called by TPFILENAME
%   
% 2012, Alexander Heimel
%

if nargin<2
    frame = [];
end
if isempty(frame)
    frame = 1;
end
if nargin<3
    channel = [];
end
if isempty(channel)
    channel = 1;
end

if length(channel)>1
    error('DEZEEUW/TPFILENAME_SETUPDEPENDENT: Too many channels requested');
end
if channel>length(record.channels)
    error('DEZEEUW/TPFILENAME_SETUPDEPENDENT: Too many channels requested');
end

    
switch record.channels(channel)
    case 525
        channel_width = 50;
    case 595 
        channel_width = 40;
    otherwise
        channel_width = nan;
        disp('DEZEEUW/TPFILENAME_SETUPDEPENDENT: Unknown channel width');
end

if isnumeric(frame)
    fmiddle = [' - PMT [' num2str(record.channels(channel)) '-' num2str(channel_width) ']' ...
        ' _C' num2str(channel-1,'%02d') '_Time Time' num2str(frame-1,'%04d') '.ome'] ;
else
    fmiddle = [' - PMT [' num2str(record.channels(channel)) '-' num2str(channel_width) ']' ...
        ' _C' num2str(channel-1,'%02d') '_Time Time' frame '.ome'] ;
end

ext = '.tif';
