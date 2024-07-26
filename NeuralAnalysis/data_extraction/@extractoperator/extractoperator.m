function [exop] = extractoperator(dummy)
%
%  Base class for extraction operators

data.input_types = {}; data.output_types = {};

exop = class(data,'extractoperator');
