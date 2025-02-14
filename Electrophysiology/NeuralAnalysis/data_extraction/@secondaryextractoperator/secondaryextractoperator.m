function [secop] = secondaryextractoperator(op)
%
%  SECOP = SECONDARYEXTRACTOPERATOR(EXOP)
%
%  Base class for secondary extraction operators.
%  Secondary operators are second-pass extractors.
%  They are children of extractoperators.
%  One can pass a dummy for EXOP or an extractoroperator,
%  which should be the first-pass extractoroperator.

exop = extractoperator(5);
if isa(op,'extractoperator'),
   data.exop = op;
else, data.exop = exop;
end;
secop = class(data,'secondaryextractoperator',exop);
