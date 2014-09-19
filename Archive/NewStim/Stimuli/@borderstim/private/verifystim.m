function [good, errormsg] =verifystim(params, paramlist)

% note: params must be a struct, NOT an object

proceed = 1;
errormsg = '';

for i = 1:length(paramlist)
    field = paramlist(i).field;
    if isempty(paramlist(i).size) % cell
        if ~iscell(getfield( params,field))
            disp(['Parameter ' field ' is not of type cell.']);
            proceed = 0;
            break;
        end
    elseif size( getfield( params,field)) ~= paramlist(i).size
        disp(['Parameter ' field ' is not of size ' mat2str( paramlist(i).size)]);
        proceed = 0;
        break;
    end
end


good = proceed;
