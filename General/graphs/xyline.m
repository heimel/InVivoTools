function h=xyline( arg)
%XYLINE plots a x=y line in an axis
%
%  H = XYLINE(ARG)
%
%    ARG = '-k' by default
%
% 2013-2014, Alexander Heimel
%

if nargin<1
    arg = '';
end
if isempty(arg)
    arg = 'k-';
end

yl=ylim;
xl=xlim;
low = max(yl(1),xl(1));
high = min(yl(2),xl(2));
holdon = ishold;
hold on
h = plot([low high],[low high],arg);
if ~holdon
    hold off
end

