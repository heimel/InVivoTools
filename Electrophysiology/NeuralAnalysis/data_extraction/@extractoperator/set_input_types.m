function newop = set_input_types(op,type)

%  NEWOP = SET_INPUT_TYPES(EXOP,TYPE)
%
%  Sets the output type for an extractor object.   Necessary because of the
%  way MATLAB handles objects.

op.input_types = type; newop = op;
