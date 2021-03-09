function [x,y]=trace_curve(fig,n)
%TRACE_CURVE traces a given curve by pointing and clicking
%
% [X,Y] = TRACE_CURVE( FIG, N )
%   FIG can be figure handle or image filename, defaults to GCF
%   N is number of datasets/lines to gather, defaults to 1.
%
% 2008-2018, Alexander Heimel
%

if nargin<2 || isempty(n)
    n = 1;
end
if nargin<1
    if ~isempty(get(0,'children'))
        fig = gcf;
    else
        [filename, pathname, filterindex] = uigetfile('*.*', 'Select an image file');
        fig = fullfile(pathname,filename);
    end
end

if ischar(fig) % filename
    img = imread(fig);
    fig = figure('WindowStyle','normal');
    image(img);
    axis image off;
elseif isnumeric(fig) || ishandle(fig) % then figure handle
    figure(fig);
end

ax = axis;
h = [];
figname = get(fig,'Name');
try
    
    disp('Click left bottom corner');
    set(fig,'name','Click left bottom corner');
    [left,bottom] = ginput(1);
    h.bottom = line([ax(1) ax(2)],[bottom bottom],'linestyle','--');
    h.left = line([left left],[ax(3) ax(4)],'linestyle','--');
    
    disp('Click top right corner');
    set(fig,'name','Click top right corner');
    [right,top]=ginput(1);
    h.right = line([right right],[ax(3) ax(4)],'linestyle','--');
    h.top = line([ax(1) ax(2)],[top top],'linestyle','--');
    
    
    prompt={'Left x coordinate:','Right x coordinate:','x is log axis?'...
        'Bottom y coordinate:','Top y coordinate:','y is log axis?'};
    name='Input for Peaks function';
    numlines=1;
    defaultanswer={'0','1','0','0','1','0'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    xl=eval(answer{1});
    xr=eval(answer{2});
    switch lower(answer{3})
        case {'1','yes','y'}
            xla=1;
            xl=log10(xl);
            xr=log10(xr);
        case {'0','no','n'}
            xla=0;
        otherwise
            disp('Did not understand if x-axis is logarithmic. use yes/y or no/n');
    end
    yb=eval(answer{4});
    yt=eval(answer{5});
    switch lower(answer{6})
        case {'1','yes','y'}
            yla=1;
            yb=log10(yb);
            yt=log10(yt);
        case {'0','no','n'}
            yla=0;
        otherwise
            disp('Did not understand if y-axis is logarithmic. use yes/y or no/n');
    end
    
    disp('Left-click on points. Right-click to erase last point. Press a key when a single set is finished')
    set(fig,'name','Left-click on points. Right-click to erase last point. Press return to finish set.');
    hold on
    h.p = [];
    x = cell(n,1);
    y = cell(n,1);
    for i=1:n
        x{i} = [];
        y{i} = [];
        key = 1;
        while key <4
            [tx,ty,key]=ginput(1);
            if isempty(key)
                key = 13;
            end
            switch key
                case 1
                    x{i} = [x{i} tx];
                    y{i} = [y{i} ty];
                    h.p = [h.p plot(tx,ty,'.r')];
                    
                case {2,3}
                    if length(x{i})>1
                        x{i} = x{i}(1:end-1);
                        y{i} = y{i}(1:end-1);
                        delete( h.p(end) );
                        h.p = h.p(1:end-1);
                    end
            end
        end
        x{i}=(x{i}-left)/(right-left)*(xr-xl)+xl;
        if xla %  log axis
            x{i} = 10.^x{i};
        end
        y{i} = (y{i}-bottom)/(top-bottom)*(yt-yb)+yb;
        if yla %  log axis
            y{i} = 10.^y{i};
        end
        
        disp(['x{' num2str(i) '} = ' mat2str(x{i})]);
        disp(['y{' num2str(i) '} = ' mat2str(y{i})]);
    end
    
    if n==1
        x=x{1};
        y=y{1};
    end
    
catch me
    set(fig,'name',figname);
    removetrace(h);
    rethrow(me)
end
set(fig,'name',figname);
removetrace(h);

function removetrace( h )
if ~isempty(h)
    % delete points and lines
    f = fieldnames(h);
    for i=1:length(f)
        if all(ishandle(h.(f{i})))
            delete(h.(f{i}));
        end
    end
end
