function [go, stim] = get_gostim(lpt)
%GET_GOSTIM reads go signal and stimulus number on parallelport or arduino
%
%   [GO, STIM] = GET_GOSTIM(LPT)
%   2004-2013, Alexander Heimel

if nargin<1
    disp('GET_GOSTIM: No lpt given. Call lpt=open_parallelport first.');
    return
end

go = 0;
stim = 0;

switch class(lpt)
    case 'serial' % assume arduino
        try
            fopen(lpt);
        end
        readasync(lpt);status = fread(lpt);
        switch lower(host)
            case 'andrewstim'
                go = (bitand(status,8)==8);
                stim = 0;
                stim = stim + (bitand(status,1)==1);
                stim = stim + 2*(bitand(status,128)==128);
                stim = stim + 4*(bitand(status,4)==4);
                stim = stim + 8*(bitand(status,2)==2);
                stim = stim + 16*(bitand(status,16)==16);
                stim = stim + 32*(bitand(status,64)==64);
                stim = stim + 64*(bitand(status,32)==32);
            otherwise % 
                stim = bitand(status,2^7-1); % remove bit 7 (GO bit)
                go = (bitand(status,2^7)>0);
                
                
%                 logmsg('TEMPORARY CHANGING 8 to 4');
%                 if stim==8
%                     stim = 4;
%                 end
                
        end
    otherwise % assume lpt
        status = lpt.read;
        stim = bitand(status,2^7-1); % remove bit 7 (GO bit)
        stim = bitshift(stim,-3);
        go = ~bitand(status,2^7);
end

