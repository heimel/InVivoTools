function connect_children( varargin )
%CONNECT_CHILDREN connects children of an axis
%
%  CONNECT_CHILDREN( CHILD1, CHILD2, ... )
%       CHILDX is a vector of child handles, or a vector of childen number
%       of the current axis
%
% 2013, Alexander Heimel

for i=1:length(varargin)
    child = varargin{i};
    
    if length(child)<2
        continue
    end
    
    if ~ishandle(child(1)) || ~strcmp(get(child(1),'type'),'line')
        children = get(gca,'children');
        child = children(child);
    end
    
    
    x = [];
    y = [];
    for c = child(:)'
        x = [x get(c,'xdata')];
        y = [y get(c,'ydata')];
    end
    set(child(1),'xdata',x);
    set(child(1),'ydata',y);
    
end

