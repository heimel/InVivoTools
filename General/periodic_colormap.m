function map=periodic_colormap(period)
%PERIODIC_COLORMAP produces a colormap that is periodic
%
%   MAP=PERIODIC_COLORMAP(PERIOD)
%      PERIOD is number of separate colors
%    matlab default colormap is periodic, but goes from
%    [0.5625 0 0] to [0 0 0.5625], which looks very
%    discontinuous
%
% Sept 2003, Alexander Heimel (heimel@brandeis.edu)
  
map=ones(period,3);  

map(:,1)=shiftcol(hump(period,0,2/8,4/8,6/8),  round(3/8 *period));
map(:,2)=shiftcol(hump(period,0,2/8,4/8,6/8),  round(1/8*period));
map(:,3)=shiftcol(hump(period,0,2/8,4/8,6/8),  round(-1/8*period));


function column=hump(period,start,starttop,stoptop,stop)
  column=zeros(period,1);
  for i=floor(period*start):floor(starttop*period)
    column(i+1)= (i-floor(period*start))/period/(starttop-start);
  end
  for i=ceil(starttop*period):floor(stoptop*period)
    column(i+1)=1;
  end
  for i=ceil(stoptop*period):floor(period*stop)
    column(i+1)= 1 - (i-ceil(period*stoptop))/period/(stop-stoptop);
  end
      
    
function newcol=shiftcol(col,nrows)
  newcol=col;

  if nrows>0
    newcol(1:nrows)=col(end-nrows+1:end);
    newcol(nrows+1:end)=col(1:end-nrows);
  else
    newcol(end+nrows+1:end)=col(1:abs(nrows));
    newcol(1:end+nrows)=col(abs(nrows)+1:end);
  end
