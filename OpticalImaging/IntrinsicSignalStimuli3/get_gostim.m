function [go, stim] = get_gostim(lpt)
%GET_GOSTIM reads go signal and stimulus number on parallelport or arduino
%
%   [GO, STIM] = GET_GOSTIM(LPT)
%   2004-2013, Alexander Heimel

go = 0;
stim = 0;

switch class(lpt)
    case 'serial' % assume arduino
        try
            fopen(lpt);
        end
      %  [status,count] = fscanf('%d',lpt);
      readasync(lpt);status= fread(lpt)
%status
 %       fclose(lpt); 
        
    %    status = str2num(status);
        stim = bitand(status,2^7-1); % remove bit 7 (GO bit)
        go = (bitand(status,2^7)>0);

    otherwise % assume lpt
        status = lpt.read;
        stim = bitand(status,2^7-1); % remove bit 7 (GO bit)
        stim = bitshift(stim,-3);
        go = ~bitand(status,2^7);
end

