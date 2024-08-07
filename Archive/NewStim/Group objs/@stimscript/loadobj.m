function B = loadobj(A)
%STIMSCRIPT/LOADOBJ
%
% 2012, Alexander Heimel
%

if isstruct(A) 
    if ~isfield(A,'trigger')
        stims = A.Stims;
        A = rmfield( A,'Stims');
        A.trigger = [];
        A.Stims = stims;
    end
    B = class(A,'stimscript');
else
    B = A;
end

