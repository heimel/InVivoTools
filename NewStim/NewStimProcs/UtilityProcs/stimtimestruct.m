function s = stimtimestruct(stimscript, mti, stimnum)
% 
%  Part of the NeuralAnalysis package
%
%  S = STIMTIMESTRUCT(STIMSCRIPT,MTI,STIMNUM)
%
%  Takes a stimscript and timing record (MTI) and returns a struct containing
%  the following records:
%
%      stim                :   the stimulus object in position STIMNUM
%      mti                 :   the timing record(s) for that stimulus's
%                          :      presentation(s)
%
%  One may also use S = STIMTIMESTRUCT(THESTIMSCRIPTTIMESTRUCT, STIMNUM).
%      In this case, the THESTIMSCRIPTTIMESTRUCT must be one-dimensional.
%
%  See also:  STIMSCRIPTTIMESTRUCT

if nargin==2,
	if ~isstimscripttimestruct(stimscript),
		error('Input must be a stimscripttimestruct'); end;
	if length(stimscript)~=1, error('Input must be 1-d.'); end;
	stimnum = mti;  % order of these three matters
	mti = stimscript.mti;
	stimscript = stimscript.stimscript;
end;
  
o = getDisplayOrder(stimscript);
i=find(o==stimnum);
s.stim = get(stimscript,stimnum);
s.mti = mti(i);
