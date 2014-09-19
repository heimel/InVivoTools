function [go, stim]=get_gostim(lpt)
%GET_GOSTIM reads go signal and stimulus number on parallelport
%
%   [GO, STIM]=GET_GOSTIM(LPT)
%   2004, Alexander Heimel

status=lpt.read;

stim=bitand(status,2^7-1); % remove bit 7 (GO bit)
stim=bitshift(stim,-3);
go=~bitand(status,2^7);
