function res = is_neurite( str )
%IS_NEURITE returns true if string is neurite
%
%  RES = IS_NEURITE( STR )
%
% 2013, Alexander Heimel

if isempty(str)
    res = false;
    return
end

neurites = {'neurite','dendrite','axon'};

if ismember(str,neurites)
    res = true;
else
    res = false;
end