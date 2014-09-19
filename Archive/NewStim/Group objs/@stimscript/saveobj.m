function A = saveobj(stimscript)

%  NewStim/stimscript
%  FUNCTION A = SAVEOBJ(STIMSCRIPT)
%
%  Strips the object before saving so the display data structures are not
%  saved.
%

A = strip(stimscript);
