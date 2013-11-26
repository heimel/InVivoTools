function[interval,start]=SONGetSampleInterval(fid,chan)
% Finds the sampling interval on a data channel in a SON file
% i.e. the reciprocal of the sampling rate for the channel
%

% Malcolm Lidierth 03/02


FileH=SONFileHeader(fid);                                   % File header
Info=SONChannelInfo(fid,chan);                              % Channel header
header=SONGetBlockHeaders(fid,chan);
if isempty(header)
    interval = [];
    start = [];
    return
end


switch Info.kind                                            % Disk block headers
case {1,6,7,9}
    switch FileH.systemID
    case {1,2,3,4,5}                                                % Before version 6
        if (isfield(Info,'divide'))
            interval=Info.divide*FileH.usPerTime*FileH.timePerADC*1e-6; % Convert to microseconds
            start=header(2,1)*FileH.usPerTime*FileH.timePerADC*1e-6;
        else
            interval=[];
        end;
        
    case {6}                                                        % Version 6
        interval=Info.lChanDvd*FileH.usPerTime*FileH.dTimeBase;
        start=header(2,1)*FileH.usPerTime*FileH.dTimeBase;
    end;
otherwise
    warning('SONGetSampleInterval: Invalid channel type');
    return
end;

