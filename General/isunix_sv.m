function b = isunix_sv

% ISUNIX_SV - Returns 1 is computer is not a PC or MAC2.
%
% 200X, Steve VanHooser
% 2012, Alexander Heimel

if strncmp(computer,'PC',2)
    b = 0;
elseif strcmp(computer,'MAC2')
    b = 0;
else
    b = 1;
end
