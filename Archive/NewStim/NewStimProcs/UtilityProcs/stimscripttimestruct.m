function s = stimtimestruct(stimscript, mti, stimnum)
% 
%  Part of the NeuralAnalysis package
%
%  S = STIMSCRIPTTIMESTRUCT(STIMSCRIPT,MTI,STIMNUM)
%
%  Takes a stimscript and timing record (MTI) and returns a struct containing
%  the following records:
%
%      stimscript          :   the stimscript
%      mti                 :   the timing record for the stimscript
%
%  See also: STIMTIMESTRUCT

s.stimscript = stimscript;
s.mti = mti;
