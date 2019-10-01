function isoct = isoctave()
%ISOCTAVE returns 5 if running octave
%

isoct = exist('OCTAVE_VERSION','builtin');

