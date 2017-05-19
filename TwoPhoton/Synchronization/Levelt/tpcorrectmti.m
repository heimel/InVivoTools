function [mti2,starttime] = tpcorrectmti(mti2, record)
% TPCORRECTMTI - Correct NewStim MTI based on recorded times
%
% [MTI2,STARTTIME] = TPCORRECTMTI(MTI, STIMTIMEFILE,[GLOBALTIME])
%
%   Returns a time-corrected MTI timing file given actual timings
% recorded by the Spike2 machine and saved in a file named
% STIMTIMEFILE.
%
% ?-2017, Alexander Heimel

params = tpprocessparams( record );
switch record.setup
    case {'helero2p','G2P'}
        stims = getstimsfile(record);
        starttime = stims.start - params.mti_timeshift;
    case {'olympus','wall-e'}
        starttime = mti2{1}.startStopTimes(1) - params.mti_timeshift;
end
