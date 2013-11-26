function ci = getclutindex(cca, stimnum)

%  GETCLUTINDEX - Return clut index number for COMPOSE_CA stim.
%
%    CI = GETCLUTINDEX(MYCOMPOSE_CA, STIMINDEX)
%
%  Returns the clut index number for stimulus STIMINDEX in a
%  COMPOSE_CA object MYCOMPOSE_CA.
%
%  See also:  COMPOSE_CA/SETCLUTINDEX, COMPOSE_CA

if stimnum>=1&stimnum<=numStims(cca),
	ci = cca.clutindex(stimnum);
else, error(['STIMINDEX must be in 1..numStims.']);
end;
