function status = check_network
%CHECK_NETWORK returns 1 if google can be reached, as a network check
%
% 2014, Alexander Heimel
%

[s,status] = urlread('http://www.google.com');
