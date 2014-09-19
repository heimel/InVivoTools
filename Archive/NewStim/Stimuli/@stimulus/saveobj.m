function A = saveobj(stim)

%  NewStim/stimulus
%  FUNCTION A = SAVEOBJ(STIM)
%
%  Strips the object before saving so the display data structures are not
%  saved.
%

A = strip(stim);
