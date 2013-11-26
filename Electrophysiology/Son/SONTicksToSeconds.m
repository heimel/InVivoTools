function[out]=SONTicksToSeconds(fid,in)
% Convert array 'in' containing SON file event or marker times in clock ticks
% to 'out' with the timings in seconds.
% 'fid' is the source file identifier

% Malcolm Lidierth 03/02


FileH=SONFileHeader(fid);

    if (FileH.systemID==6)                                      % Convert clock ticks to seconds
        out=in*FileH.usPerTime*FileH.dTimeBase;
    else
        out=in*FileH.usPerTime*1e-6; 
    end;
