function scatterplot(X, varargin);
% SCATTERPLOT -- plot data points
%
%	SCATTERPLOT (X) draws a scatter plot with a dot for each row
%	in X.  If X has more than two columns then each dimension is
%	plotted against each other one to form a triangular set of
%	subplots in the current figure.
%
%	OPTIONS:
%
%	'class'		- vector containing a class label for each
%			  point.  If any (or all) of markercolor,
%			  markersize or markerstyle are cell arrays
%			  the label is used to index the cell array to
%			  set the marker appearance.
%	'color'		- color for marker border and fill (if used).
%			  Defaults to cell array of 'ColorOrder'
%			  property of axes. 
%	'fill'		- boolean indicating whether to fill marker
%	'marker'	- marker symbol to use
%	'markeredgecolor' - color for marker border: may be a string
%			  or [r,g,b] vector 
%	'markerfacecolor' - color for marker fill: may be a string
%			  or [r,g,b] vector
%	'markersize'	- marker size (default is 1)
%	'projection'	- plot only the specified dimensions
%	'shrink'	- resize the axes to exactly surround
%			  the points (on by default)


% Copyright 1996, 1997 Maneesh Sahani maneesh@caltech.edu

class	    = ones(size(X, 1), 1);
projection  = 1:size(X, 2);
shrink	    = 1;
marker	    = '.';
color	    = num2cell(get(gca, 'colororder'), 2);
fill	    = 0;
markeredgecolor = 'auto';
markerfacecolor = 'none';
markersize  = 1;

assign(varargin{:});

if length(projection) == 2
  d1 = projection(1);
  d2 = projection(2);
  classes = unique(class)'; % changed from uniq() sdv
  for c = classes

    ic = find(class == c);
    h = plot (X(ic,d1), X(ic,d2), 'linestyle', 'none');
    set(gca, 'nextplot', 'add');

    if iscell(color)
      set (h, 'Color', color{c});
    else
      set (h, 'Color', color);
    end

    if iscell(fill)
      if (fill{c}) set (h, 'markerfacecolor', get(h, 'color')); end
    else
      if (fill) set (h, 'markerfacecolor', get(h, 'color')); end
    end
    
    if iscell(marker)
      set (h, 'Marker', marker{c});
    else
      set (h, 'Marker', marker);
    end
	
    if iscell(markersize)
      set(h, 'MarkerSize', markersize{c});
    else
      set(h, 'MarkerSize', markersize);
    end

    if iscell(markeredgecolor)
      set(h, 'MarkerEdgeColor', markeredgecolor{c});
    else
      set(h, 'MarkerEdgeColor', markeredgecolor);
    end

    if iscell(markerfacecolor)
      set(h, 'MarkerFaceColor', markerfacecolor{c});
    else
      set(h, 'MarkerFaceColor', markerfacecolor);
    end
    
    if (shrink > 0)
      axis([min(X(:,d1)) max(X(:,d1)) min(X(:,d2)) max(X(:,d2))]);
    end
    
  end
  
else
  np = length(projection);
  for x = 1:np-1
    for y = x+1:np
      subplot (np-1, np-1, (np-1)*(y-2) + x)
      scatterplot (X, varargin{:}, 'projection', projection([x,y]));
      if x == 1
	ylabel(num2str(y));
      end
      if y == np
	xlabel(num2str(x));
      end
    end
  end

end

