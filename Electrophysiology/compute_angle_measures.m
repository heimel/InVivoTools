function measures = compute_angle_measures( measures )
%COMPUTE_ANGLE_MEASURES compute some specific angle measures
%
%  RECORD = COMPUTE_ANGLE_MEASURES( RECORD )
%
%
% 2013 Alexander Heimel
%

if ~strcmp(measures.variable,'angle') && ~strcmp(measures.variable,'gnddirection')
    return
end

if ~iscell(measures.curve)
    measures.curve = {measures.curve};
end

n_triggers = length(measures.triggers);
for t=1:n_triggers
    measures.range{t} = measures.range{t} - measures.preferred_stimulus{1};
    measures.range{t}(measures.range{t}<=-180) = measures.range{t}(measures.range{t}<=-180)+360;
    measures.range{t}(measures.range{t}>180) = measures.range{t}(measures.range{t}>180)-360;
    

    [measures.orientation_index{t},measures.direction_index{t}] = ...
        compute_orientationindex( measures.range{t}, measures.response{t} );
    
    [measures.orientation_selectivity_index{t},measures.direction_selectivity_index{t}] = ...
        compute_orientation_selectivity_index( measures.range{t}, measures.response{t} );
    
    measures.tuningwidth{t} = compute_tuningwidth( measures.range{t}, measures.response{t} );
end
