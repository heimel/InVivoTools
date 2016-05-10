function h = arrow_on_axis(data,which_axis,which_handle,which_function,location)
%ARROW_ON_AXIS add descriptive arrow on figure axis
%
% H = ARROW_ON_AXIS(DATA,WHICH_AXIS,WHICH_HANDLE,WHICH_FUNCTION,LOCATION)
%
%   all arguments are optional
%          WHICH_AXIS could be 'x', 'y', 'both' (default)
%          WHICH_HANDLE will default to GCA
%          WHICH_FUNCTION will default to @MEAN
%          LOCATION could be 'inside', 'outside' (default)
%
% 2016, Alexander Heimel
%

if nargin<5 || isempty(location)
    location = 'outside';
end

if nargin<4 || isempty(which_function)
    which_function = @mean;
end

if nargin<3 || isempty(which_handle)
    which_handle = gca;
end

if nargin<2 || isempty(which_axis)
    which_axis = 'both';
end

if nargin<1 || isempty(data)
    data = [];
    g = get(which_handle);
    if isfield(g,'XData')
        xdata = g.XData;
        ydata = g.YData;
    else
        g = get(get(which_handle,'children')); 
        if ~isfield(g,'XData')
            h = [];
            return
        end
        xdata = g.XData;
        ydata = g.YData;
    end        
else
    xdata = data;
    ydata = data;
end

switch location
    case 'inside' 
        side = 1;
    case 'outside' 
        side = -1;
end

switch which_axis
    case 'both' 
        h = arrow_on_axis(data,'x',which_handle,which_function,location);
        h = [h arrow_on_axis(data,'y',which_handle,which_function,location)];
    case 'x'
        data = xdata;
        m = which_function(data);
        p = get(which_handle,'position');
        y = p(2);
        l = p(3)*0.1;
        ax = axis;
        m = m - ax(1);
        m = m / (ax(2)-ax(1));
        h = annotation('arrow',[p(1)+m*p(3) p(1)+m*p(3)],[y+l*side y]);
    case 'y'
        data = ydata;
        m = which_function(data);
        p = get(which_handle,'position');
        x = p(1);
        l = p(4)*0.1;
        ax = axis;
        m = m - ax(3);
        m = m / (ax(4)-ax(3));
        h = annotation('arrow',[x+l*side x],[p(2)+m*p(4) p(2)+m*p(4)]);
end

