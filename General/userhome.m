function home = userhome
%USERHOME returns user's home folder
%
% 2015, Alexander Heimel

persistent home_pers


if isempty(home_pers)
    if ispc
        home_pers = getenv('userprofile');
    else
        home_pers = lower(getenv('HOME'));
    end
end

home = home_pers;
