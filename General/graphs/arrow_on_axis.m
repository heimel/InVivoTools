function h = arrow_on_axis(data,which_axis,which_handle,which_function,location,clr)
%ARROW_ON_AXIS add descriptive arrow on figure axis
%
% H = ARROW_ON_AXIS(DATA,WHICH_AXIS,WHICH_HANDLE,WHICH_FUNCTION,LOCATION)
%
%   all arguments are optional
%          WHICH_AXIS could be 'x', 'y', 'both' (default)
%          WHICH_HANDLE will default to GCA
%          WHICH_FUNCTION will default to @NANMEAN
%          LOCATION could be 'inside' (default), 'outside', 'far_inside',
%          'far_outside'
%
%   DATA is [Mx2] array, with x-values in first column, y-values in second
%
% 2016, Alexander Heimel
%

if nargin<6 || isempty(clr)
    clr = [0 0 0];
end

if nargin<5 || isempty(location)
    location = 'inside';
end

if nargin<4 || isempty(which_function)
    which_function = @nanmean;
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
        xdata = [];
        c = get(which_handle,'children');
        while ~isempty(c)
            g = get(c(1));
            c(1) = [];
            if isfield(g,'XData')
                xdata = g.XData;
                ydata = g.YData;
            end
        end
        if isempty(xdata)
            h = [];
            return
        end
    end
else
    if size(data,2)==2
        xdata = data(:,1);
        ydata = data(:,2);
    else
        xdata = data;
        ydata = data;
    end
end

switch location
    case 'inside'
        side = 1;
        axindp = 0;
    case 'far_inside'
        side = -1;
        axindp = 1;
    case 'outside'
        side = -1;
        axindp = 0;
    case 'far_outside'
        side = 1;
        axindp = 1;
end


switch which_axis
    case 'both'
        h = arrow_on_axis(xdata,'x',which_handle,which_function,location,clr);
        h = [h arrow_on_axis(ydata,'y',which_handle,which_function,location,clr)];
        return
    case 'x'
        axind = 3;
        data = xdata;
        
        axis(which_handle);
        ax = axis;
        l = (ax(axind+1)-ax(axind))*0.1;
        m = which_function(data);
        start = [m ax(axind+axindp)+side*l];
        stop = [m ax(axind+axindp)];
    case 'y'
        axind = 1;
        data = ydata;

        axis(which_handle);
        ax = axis;
        l = (ax(axind+1)-ax(axind))*0.1;
        m = which_function(data);
        start = [ax(axind+axindp)+side*l m];
        stop = [ax(axind+axindp) m];
end
h = arrow( start,stop,7,'Length',25);
set(h,'Edgecolor',clr);
set(h,'Facecolor',clr);
axis(ax);


