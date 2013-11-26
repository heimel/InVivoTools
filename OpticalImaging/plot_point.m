function plot_point(x,r,barcolor)
if nargin<3
  barcolor=[];
end
if isempty(barcolor)
  barcolor=0.7*[1 1 1];
end
if ~isempty(r)
  if length(r)>1
    h=errorbar( x,nanmean(r),sem(r));
    set(h,'color',0.0*[1 1 1]);
  end
  if barcolor~=-1
    h=bar( x,nanmean(r));
    set(h,'facecolor',barcolor);
  end
end
