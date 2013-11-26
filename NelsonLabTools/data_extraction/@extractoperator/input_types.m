function it = input_types(exop)

%  IT = INPUT_TYPES(EXOP)
%
%  Returns a cell list of what input types this extractor operator can operate
%  on.  The cell list is a list of strings.
%
%  See also:  EXTRACTOPERATOR

it = exop.input_types;
