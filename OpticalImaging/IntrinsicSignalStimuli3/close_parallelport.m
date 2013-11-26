function close_parallelport( lpt )
% CLOSE_PARALLLELPORT
%
% 2013, Alexander Heimel

switch class(lpt)
    case 'serial' % assume arduino
        try
            fclose(lpt);
            delete(lpt);
        end
    otherwise % assume lpt
        try
            delete(lpt)
        end
end
