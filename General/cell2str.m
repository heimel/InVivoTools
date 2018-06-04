function str = cell2str(theCell,accolades,quotes)
%CELL2STR converts 1-dim cell lists of only chars and matrices to string
%
%  STR = CELL2STR( THECELL, ACCOLADES, QUOTES )
%
% 200X, Steve Vanhooser
% 2012-2018, Alexander Heimel

if nargin<2 || isempty(accolades)
    accolades = true;
end
if nargin<3 || isempty(quotes)
    quotes = true;
end

if accolades
    str = '{';
else
    str ='';
end

if ~iscell(theCell)
    theCell = {theCell};
end
if ~isempty(theCell)
    for i=1:length(theCell)
        if ischar(theCell{i})
            if quotes
                str = [str '''' theCell{i} ''', '];
            else
                str = [str theCell{i} ', '];
            end
            
        elseif isnumeric(theCell{i})
            str = [str mat2str(theCell{i}) ', '];
        end
    end
    str = [str(1:max(1,end-2))];
else
    str = '';
end
if accolades
    str = [str '}'];
end

