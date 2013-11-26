function newop = set_output_types(op,type)

%  NEWOP = SET_OUTPUT_TYPES(EXOP,TYPE)
%
%  Sets the output type for an extractor object.   Necessary because of the
%  way MATLAB handles objects.

op.output_types = type; newop = op;
