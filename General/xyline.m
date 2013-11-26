function xyline
%XYLINE plots a x=y line in an axis
%
% 2013, Alexander Heimel
%

yl=ylim;
xl=xlim;
low = max(yl(1),xl(1));
high = min(yl(2),xl(2));
holdon = ishold;
hold on
plot([low high],[low high],'-k');
if ~holdon
    hold off
end

