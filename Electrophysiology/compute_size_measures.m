function measures = compute_size_measures( measures )
%COMPUTE_SIZE_MEASURES compute some specific size tuning measures
%
%  RECORD = COMPUTE_SIZE_MEASURES( RECORD )
%
%
% 2014 Alexander Heimel
%

if ~strcmp(measures.variable,'size') 
    return
end

for t=1:length(measures.triggers)
    measures.suppression_index{t} = ...
        compute_suppression_index( measures.range{t}, measures.response{t} );
end
