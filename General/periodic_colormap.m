function map = periodic_colormap(steps)
%PERIODIC_COLORMAP produces a colormap that is periodic (cyclic)
%
%   MAP = PERIODIC_COLORMAP(STEPS)
%      STEPS is number of separate colors
%
% 2003, Alexander Heimel

map = ones(steps,3);

map(:,1) = shiftcol(hump(steps,0,2/8,4/8,6/8),  round(3/8 *steps));
map(:,2) = shiftcol(hump(steps,0,2/8,4/8,6/8),  round(1/8*steps));
map(:,3) = shiftcol(hump(steps,0,2/8,4/8,6/8),  round(-1/8*steps));

function column = hump(period,start,starttop,stoptop,stop)
column = zeros(period,1);
for i = floor(period*start):floor(starttop*period)
    column(i+1) = (i-floor(period*start))/period/(starttop-start);
end
for i = ceil(starttop*period):floor(stoptop*period)
    column(i+1) = 1;
end
for i = ceil(stoptop*period):floor(period*stop)
    column(i+1) = 1 - (i-ceil(period*stoptop))/period/(stop-stoptop);
end

function newcol = shiftcol(col,nrows)
newcol = col;

if nrows>0
    newcol(1:nrows) = col(end-nrows+1:end);
    newcol(nrows+1:end) = col(1:end-nrows);
else
    newcol(end+nrows+1:end) = col(1:abs(nrows));
    newcol(1:end+nrows) = col(abs(nrows)+1:end);
end


