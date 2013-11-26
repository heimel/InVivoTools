function str = var2str( v )
%VAR2STR converts anything to string
%
%  STR = VAR2STR( V )
%
% 2009, Alexander Heimel
%

if iscell( v)
    str = cell2str( v);
elseif isnumeric(v)
    str = mat2str( v);
elseif ischar( v)
    str = v;
else
    error('VAR2STR: do not know how to handle variable');
end
