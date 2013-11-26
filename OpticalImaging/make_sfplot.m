function make_sfplot(vals,xvals)
%MAKE_SFPLOT
%
%   MAKE_SFPLOT(VALS,XVALS)
%
  if nargin<2
    xvals=[0.05 0.15 0.45 0.9];
  end
  
  make_plot(vals(2:end)*100,xvals,'-ok','Spatial frequency (cpd)',...
	    'Luminance change (%)',[0.04 1]);
  set(gca,'XScale','log');
  
  set(gca,'TickLength',3*get(gca,'TickLength'));
  smaller_font(-10);
  bigger_linewidth(5);
