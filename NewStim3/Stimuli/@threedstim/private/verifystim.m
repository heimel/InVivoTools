function [good, errormsg] =verifystim(params, paramlist)
%VERIFYSTIM verifies parameters off a struct array with size fields
%
% note: params must be a struct, NOT an object
%
% empty size denotes a cell list
% range is not checked
%
% 2010, Alexander Heimel, based on function by Steve Vanhooser

proceed = 1;
errormsg = '';

for i = 1:length(paramlist)
    field = paramlist(i).field;
    param = getfield( params, field); %#ok<GFLD>
    if isempty(paramlist(i).size) % cell
        if ~iscell( param)
            errormsg=['Parameter ' field ' is not of type cell.'];
            proceed = 0;
            break;
        end
    elseif ~prod(double(size(param) == paramlist(i).size)) 
        if isnan(paramlist(i).size(1)) & (size( param,2) == paramlist(i).size(2) | isempty(param))  %#ok<OR2,AND2>
            %
        elseif isnan(paramlist(i).size(2)) &  (size( param,1) == paramlist(i).size(1) | isempty(param)) %#ok<OR2,AND2>
            %
        else
            errormsg = ['Parameter ' field ' is not of size ' mat2str( paramlist(i).size)];
            proceed = 0;
            break;
        end
    end
end

good = proceed;
