function res = is_linearroi( str )
%IS_LINEARROI return true if ROI type is linear
%
%  RES = IS_LINEARROI( STR )
%
% 2013, Alexander Heimel
%

if isempty(str)
    res = false;
    return
end

if is_neurite(str)
    res = true;
    return
end

if ismember(str,{'pia','line'})
    res = true;
else
    res = false;
end