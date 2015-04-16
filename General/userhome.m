function home = userhome
%USERHOME returns user's home folder
%
% 2015, Alexander Heimel

persistent home_pers


if isempty(home_pers)
    home_pers = lower(getenv('HOME'));
end

home = home_pers;
