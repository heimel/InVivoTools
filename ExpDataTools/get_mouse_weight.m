function weight = get_mouse_weight( record )
%GET_MOUSE_WEIGHT returns last measured weight from mouse record
%
% W = GET_MOUSE_WEIGHT( RECORD )
%
% 2010, Alexander Heimel
%
if isempty(record.weight)
    weight = NaN;
    return
end
weight_eval = eval(record.weight);
if isnumeric(weight_eval)
    weight = weight_eval;
elseif iscell(weight_eval)
    weight = weight_eval{end}; % take last weight measurement
    disp('GET_MOUSE_WEIGHT returns only last measured weight.');
else
    disp(['Cannot parse weight of mouse ' mouse.mouse ]);
    weight = NaN;
end