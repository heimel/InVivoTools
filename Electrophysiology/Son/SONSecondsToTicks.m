function[out]=SONSecondsToTicks(fid,in)
% Convert array 'in' containing SON file event or marker times in seconds
% to 'out' with the timings in clock ticks.
% 'fid' is the source file identifier

% Malcolm Lidierth 03/02


FileH=SONFileHeader(fid);

    if (FileH.systemID==6)                                      % Convert clock ticks to seconds
        out=in/FileH.usPerTime/FileH.dTimeBase;
    else
        out=in/FileH.usPerTime/1e-6; 
    end;
    
    out=int32(round(out));                                      % Round to nearest integer and convert to int32
                                                                % Rounding should stop out-by-one errors when converting disk derived
                                                                % data back to clock ticks.
                                                                