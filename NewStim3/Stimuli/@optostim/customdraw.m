function [done,stamp,stiminfo] = customdraw( stim, stiminfo, MTI)
%OPTOSTIM/CUSTOMDRAW
%
% 2016, Alexander Heimel
%

params = getparameters(stim);

switch params.waveform
    case 'triggerup'
        StimSerialGlobals
        StimSerial('rts',StimSerialStim,1);
        WaitSecs(params.duration);
        StimSerial('rts',StimSerialStim,0);
    otherwise
        error('OPTOSTIM:NOT_IMPLEMENTED',['Waveform ' params.waveform ' is not implemented']);
end

done = 1;
stamp = 1;    



