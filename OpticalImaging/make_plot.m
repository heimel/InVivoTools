function make_plot(vals,xvals,marker,xlab,ylab,range)
%MAKE_PLOT 

if nargin<6; range=[]; end
if nargin<5; ylab=[]; end
if nargin<4; xlab=[]; end
if nargin<3; marker=[]; end
if nargin<2; xvals=[]; end

if isempty(xvals)
  xvals=(1:length(vals));
end
if isempty(marker)
  marker='o-k';
end

  
figure;
h=plot(xvals,vals,marker);

xlabel(xlab);
ylabel(ylab);

if length(range)==4
  axis(range);
elseif length(range)==2
  ax=axis;
  ax([1 2])=range;
  axis(ax);
end

box off
