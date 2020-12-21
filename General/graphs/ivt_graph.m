function h=ivt_graph(y,x,varargin)
%GRAPH produces scientific plots
%
%  H = GRAPH(Y,X,VARARG)
%
%  Y,X is cell list of cell list of data vectors Y and X
%    Y{measures}{group}[data]
%
%  H is structure containing image handles and info
%
%  VARARG is a selection of option names and values. List of options is
%  given below ([] denotes default value):
%     'axishandle',[]
%     'showpoints',{0,[1],2}
%     'test',{['ttest'],'kruskal_wallis_test','none'}
%     'spaced',{[0],1,2,3} % spacing points in bar plot, see help PLOT_POINTS
%     'color',0.7*[1 1 1]
%     'errorbars',''
%     'style',{['bar'],'xy','box','hist','cumul','rose'}
%     'signif_y',[]
%     'prefax',[]
%     'xticklabels',[]
%     'xlab',''
%     'ylab',''
%     'extra_code',''
%     'rotate_xticklabels',[0] % is the rotation in degrees
%     'markers', {'none','open_triangle','closed_triangle','open_circle',['closed_circle']}
%     'markersize',[8]
%     'fontsize',[14]
%     'fontname',['arial']
%     'linestyles',''
%     'linewidth',[3]
%     'ystd',[]
%     'ny',[]
%     'bins',[]  % for (cumulative) histogram and rose
%     'tail','both'   % for significance tests
%     'legnd','' % legend, example legnd,{''wt'';''t1''}
%     'save_as',''
%     'z',{}
%     'showpairing',false
%     'extra_options',''
%
%  EXTRA_OPTIONS is a comma-separated string containing option and value
%        sort_y,asc or dec, sorts wrt y-values ascending or descending
%        min_n, # , where # is the minimal number of y-values to include a
%                           group in the graph
%        fit, linear
%        wingtipheight
%        errorbars_tick    width of tick
%        errorbars_sides   away, both, below, above, none, topline
%
%
% 2006-2020, Alexander Heimel
%

h=[];
if nargin<2
    x=[];
end
if ~iscell(y)
    y = {y};
end

% to avoid all nonsense warnings in matlab
signif_y = 0;
% dy = [];
xticklabels = [];
extra_options = '';
rotate_xticklabels = '';


color=[]; % to overload matlab function OPTIM/COLOR
fit=''; % to overload matlab function CURVEFIT/FIT

%defaults

% possible varargins with default values
pos_args={...
    'axishandle',[],...
    'bottomline','',... % none
    'showpoints',1,...
    'test','',... %'ttest',...
    'spaced',1,...
    'color',0.7*[1 1 1],...
    'errorbars','',...
    'style',strtrim(char(double(length(x)==length(y))*'xy '+ ...
    double(length(x)~=length(y))*'bar')),... % def. bar, unless as n_x==n_y
    'signif_y',[],...
    'prefax',[],...
    'xticklabels',[],...
    'xlab','',...
    'ylab','',...
    'extra_options','',...
    'extra_code','',...
    'rotate_xticklabels','0',...
    'markers','closed_circle',... % {'none','open_triangle','closed_triangle','open_circle','closed_circle'}
    'markersize',8,...
    'fontsize',14,...
    'fontname','arial',...
    'linestyles','',...
    'linewidth',[],...
    'ystd',[],...
    'ny',[],...
    'bins',[],... % for (cumulative) histogram and rose
    'tail','both',... % for significance tests
    'legnd','',...  % legend,example legnd,{wt,t1}
    'save_as','',...
    'z',{},...
    'smoothing',0,...
    'merge_x',[],...
    'transform','',... % for statistics, not implemented yet
    'showpairing',false,...
    'barwidth',[],...
    'correction',[],...
    'outlierremoval',false,...
    'normalitytest','',...
    'wingtipheight',[],...
    };

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
    if rem(nvarargin,2)==1
        warning('GRAPH:WRONGVARARG','odd number of varguments');
        return
    end
    for i=1:2:nvarargin
        found_arg=0;
        for j=1:2:length(pos_args)
            if strcmp(varargin{i},pos_args{j})==1
                found_arg=1;
                if ~isempty(varargin{i+1})
                    assign(pos_args{j}, varargin{i+1});
                end
            end
        end
        if ~found_arg
            warning('GRAPH:WRONGVARARG',['could not parse argument ' varargin{i}]);
            return
        end
    end
end

% parse extra options
if ischar(extra_options)
    extra_options=split(extra_options,',');
end
for i=1:2:length(extra_options)
    assign(strtrim(extra_options{i}),extra_options{i+1});
end

if exist('fontsize','var') && ischar(fontsize)
    fontsize = eval(fontsize);
end

if isempty(linewidth)
    switch style
        case { 'bar','box'}
            linewidth = 1;
        otherwise
            linewidth =2;
    end
end

if exist('errorbars_sides','var')
    errorbars_sides = strtrim(errorbars_sides);
    if errorbars_sides(1)=='{'
        errorbars_sides = split( errorbars_sides(2:end-1),';');
    end
end

if exist('errorbars_tick','var')
    errorbars_tick = str2double(errorbars_tick);
else
    errorbars_tick = [];
end

if ~isempty(merge_x)
    merge_x = str2double(merge_x);
end

if exist('smoothing','var')
    smoothing = str2double(smoothing);
else
    smoothing = 0;
end

if exist('outlierremoval','var') && ischar(outlierremoval)
    outlierremoval = str2double(outlierremoval);
else
    outlierremoval = 0;
end

if exist('linewidth','var')
    if ischar(linewidth) && ~isempty(linewidth)
        linewidth = str2double(linewidth);
    end
end

if exist('barwidth','var')
    if ischar(barwidth) && ~isempty(barwidth)
        barwidth = str2double(barwidth);
    end
end

if exist('markersize','var')
    if ischar(markersize)
        markersize = str2double(markersize);
    end
end

if exist('markers','var')
    markers=strtrim(markers);
    if markers(1)=='{'
        markers=split( markers(2:end-1),';');
    end
end
if exist('linestyles','var')
    linestyles=strtrim(linestyles);
    if ~isempty(linestyles) && linestyles(1)=='{'
        linestyles=split( linestyles(2:end-1),';');
    end
end

if exist('wingtipheight','var')
    if ischar(wingtipheight)
        wingtipheight = str2double(wingtipheight);
    end
end

if ~iscell(color)
    tmpcolor = color;
    color = cell(length(y),1);
    for g=1:length(y)
        color{g} = tmpcolor;
    end
    clear('tmpcolor');
end

% make graph
if isempty(axishandle)
    h.fig = figure;
else
    axes(axishandle);
    h.fig = get(gca,'parent');
end
h.p_sig = {};
hold on;
if exist('fontsize','var')
    set(gca,'FontSize',fontsize);
end

if length(prefax)==4
    axis(prefax);
end

% reformat y into cell-structure
if ~iscell(y)
    if ndims(y)>2 %#ok<ISMAT>
        errormsg('Unable to handle arrays of more than 2 dimensions');
        return
    end
    old_y = y;
    y = cell(size(old_y,1),1);
    for i = 1:size(old_y,1)
        y{i} = old_y(i,:);
    end
end

% flatten y,x,color
if iscell(y{1})
    orgy = y;
    n_measures = length(y);
    y = {};
    for i=1:n_measures
        y = {y{:},orgy{i}{:}};
    end
    if iscell(x)
        orgx = x;
        x = [];
        for i = 1:n_measures
            x = [x orgx{i}];
        end
    end
    if iscell(color)
        if iscell(color{1})
            orgcolor = color;
            color = {};
            for i = 1:n_measures
                color = {color{:},orgcolor{i}{:}};
            end
        end
    end
    if ~isempty(ystd)
        if iscell(ystd)
            if iscell(ystd{1})
                orgystd = ystd;
                ystd = {};
                for i = 1:n_measures
                    ystd = {ystd{:},orgystd{i}{:}};
                end
            end
        end
    end
    if ~isempty(ny)
        if iscell(ny)
            if iscell(ny{1})
                orgny=ny;
                ny={};
                for i=1:n_measures
                    ny={ny{:},orgny{i}{:}};
                end
            end
        end
    end
    orgxticklabels = xticklabels;
    if ~isempty(xticklabels)
        xticklabels = {};
        for i=1:n_measures
            xticklabels = {xticklabels{:},orgxticklabels{i}{:}};
        end
    end
end

if outlierremoval
    logmsg('Removing outliers');
    for i=1:length(y)
        y{i} = remove_outliers(y{i});
    end
end


switch style
    case 'surf'
        logmsg('Surf currently only works for 1 image');
        
        n_x = size(z{1},2);
        n_y = size(z{1},1);
        
        if n_x>length(x{1}) || n_y>length(y{1})
            logmsg(['Z has dimension ' mat2str(size(z{1})) ...
                ', while x has length ' num2str(length(x{1})) ...
                ' and y has length ' num2str(length(y{1}))]);
        end
        x{1} = x{1}(1:n_x);
        y{1} = y{1}(1:n_y);
        
        if size(z{1},3)>1
            logmsg(['Averaging ' num2str(size(z{1},3) ) ' frames.']);
            z{1} = mean(z{1},3);
        end
        if isnan(z{1})
            errormsg('z is not suitable for surface plot.');
            close(h.fig);
            return
        end
        surf(x{1},y{1},z{1},'EdgeColor','none');
        axis xy; axis tight; view(0,90);
    case 'image'
        logmsg('Image currently only works for 1 image');
        imagesc( y{1} );
    case 'rose'
        hold off % to clear settings from rectangular graphs
        if exist('bins','var') && ~isempty(bins) && ischar(bins)
            bins=eval(bins);
        else
            bins = 16;
        end
        if exist('rose_style','var') && strcmp(rose_style,'relative')
            polar(0,2); hold on; % ugly, need it for friederike's graph
            for i=1:length(y)
                [rose_theta(i,:),rose_r(i,:)] = rose( y{i}+pi/bins,bins);
            end
            for i=1:2:(length(y)-1)
                h.polar(i) = polar( rose_theta(i,:)-pi/bins, rose_r(i,:)./(0.0000001+rose_r(i+1,:))/sum(rose_r(i,:))*sum(rose_r(i+1,:)));
                hold on
                set(h.polar(i),'Color',color{(i-1)/2+1});
            end
        else
            % default
            for i=1:length(y)
                [rose_theta(i,:),rose_r(i,:)] = rose( y{i}+pi/bins,bins);
                h.polar(i) = polar( rose_theta(i,:)-pi/bins, rose_r(i,:));
                hold on
                set(h.polar(i),'Color',color{i});
            end
        end
        if strcmp(test,'chi2') % calculate significance
            for i = 1:length(y)
                for j=i+1:length(y)
                    logmsg(['p of chi2class test of groups ' num2str(i) ...
                        ' and ' num2str(j) ' = ' ...
                        num2str(chi2class( [rose_r(i,2:4:end) ;rose_r(j,2:4:end)]))]);
                end
            end
        end
    case {'cumul'}
        if ~isempty(bins) && ischar(bins)
            bins=eval(bins);
        end
        for i=1:length(y)
            y{i} = y{i}(~isnan(y{i})); % remove NaNs
            
            [cf_mean,histbin_centers,h.cumul(i)]=plot_cumulative( y{i},bins,color{i},1,prefax,1);
            set(h.cumul(i),'linewidth',linewidth);
        end
    case {'hist'}
        if ~isempty(bins) && ischar(bins)
            bins=eval(bins);
        end
        for i=1:length(y)
            if ~isempty(bins)
                [cf_mean,histbin_centers]=hist( y{i},bins);
            else
                [cf_mean,histbin_centers]=hist( y{i});
            end
            hist( y{i},histbin_centers);
            hh = findobj(gca,'Type','patch');
            set(hh(1),'FaceColor',color{i});
        end
    case 'pie'
        h.pie = pie(cellfun(@mean,y));
        cm=[color{:}];
        cm = reshape(cm',3,length(cm)/3)';
        colormap(cm);
        axis off square
    case 'stackedbar'
        set(gcf,'PaperPositionMode','auto');
        width=0.2;
        left=0.5-width/2;
        subplot('position',[left 0.20 width 0.7]);
        hold on;
        my = cellfun(@mean,y);
        h.stackedbar = bar([my;my],'stacked');xlim([.5 1.5]);
        cm=[color{:}];
        cm = reshape(cm',3,length(cm)/3)';
        colormap(cm);
        axis off
    case {'bar','box'}
        if isempty(x)
            x=(1:length(y));
        end
        
        % figure positioning and size
        set(gcf,'PaperPositionMode','auto');
        if isempty(axishandle)
            if length(x)>5
                p=get(gcf,'position');
                p(3)=p(3)*(length(x)/6)^0.5;
                set(gcf,'position',p);
            end
            width=min(0.6,0.2*length(x));
            left=0.5-width/2;
            subplot('position',[left 0.20 width 0.7]);
        end
        hold on;
        if length(x)>5 % broad graph, show horizontal lines
            set(gca,'YGrid','on')
        end
        
        switch style
            case 'bar'
                % calculate means
                means=zeros(1,length(y));
                for i=1:length(y)
                    means(i)=nanmean(y{i});
                end
            case 'box'
                % calculate means
                means=zeros(1,length(y));
                for i=1:length(y)
                    means(i)=nanmedian(y{i});
                end
                if isempty(errorbars)
                    errorbars = 'bootstrapmedian';
                end
        end
        
        if exist('sort_y','var')
            switch sort_y
                case 'asc'
                    [means,ind]=sort(means);
                case 'desc'
                    [means,ind]=sort(-means);
                    means=-means;
                otherwise
                    logmsg(['sort_y by ' sort_y ' is not implemented yet']);
                    ind=(1:length(means));
            end
            y = y(ind);
            color = color(ind);
            xticklabels = xticklabels(ind);
        end
        
        % plot errors
        if ~exist('errorbars_sides','var')
            errorbars_sides = 'away';
        end
        h.errorbar = plot_errorbars(y,x,ystd,ny,means,...
            errorbars,errorbars_sides,errorbars_tick,color); %#ok<*NODEF>
        
        % plot bars
        if ~exist('nobars','var')
            for i=1:length(y)
                h.bar{i}=bar(x(i), means(i) );
                if iscell(color)
                    set(h.bar{i},'facecolor',color{mod(i-1,end)+1});
                else
                    set(h.bar{i},'facecolor',color);
                end
                if ~isempty(linewidth)
                    if linewidth>0
                        set(h.bar{i},'linewidth',linewidth);
                    else
                        set(h.bar{i},'linestyle','none');
                    end
                end
                if ~isempty(barwidth)
                    set(h.bar{i},'barwidth',barwidth)
                end
            end
        end
        
        % plot points
        if showpoints
            
            x_spaced = cell(length(y),1);
            for i=1:length(y)
                [hp,x_spaced{i}] = plot_points(x(i),y{i},spaced);
                switch markers
                    case 'none'
                        set(hp,'marker','none');
                    case 'closed_circle'
                        set(hp,'marker','o');
                        set(hp,'markerfacecolor',color{mod(i-1,end)+1});
                    case 'open_circle'
                        set(hp,'marker','o');
                end
                
                if markersize>0
                    set(hp,'markersize',markersize);
                end
            end
        end
        
        if showpairing
            if ~all(cellfun(@numel,y)==numel(y{1}))
                logmsg('Not all y have same number of elements. Not showing pairing')
            else
                set(gca,'ColorOrderIndex', 1);
                if exist('x_spaced','var')
                    plot(reshape([x_spaced{:}],numel(y{1}),length(y))',...
                        reshape([y{:}],numel(y{1}),length(y))',...
                        linestyles,'linewidth',linewidth)
                else
                    plot(repmat(x,numel(y{1}),1)',...
                        reshape([y{:}],numel(y{1}),length(y))',...
                        linestyles,'linewidth',linewidth)
                end
            end
        end
        
        % compute and plot significances
        h = compute_significances( y,x, test, signif_y, ystd, ny, tail,transform, h,correction,normalitytest,wingtipheight );
        
        % tighten x-axis
        ax = axis;
        ax(1) = min(x)-0.5;
        ax(2) = max(x)+0.5;
        axis(ax);
        
    case 'xy'
        if isempty(x)
            for i=1:length(y)
                x{i}=(1:length(y{i}));
            end
        elseif ~iscell(x)
            oldx = x;
            if numel(x)==length(x) && length(x)==length(y{1})
                x = cell(length(y),1);
                for i=1:length(y)
                    x{i}=oldx;
                end
            else
                x = cell(size(oldx,1),1);
                for i=1:size(oldx,1)
                    x{i}=oldx(i,:);
                end
            end
        end
        if showpoints==0 % replace points by means
            for i=1:length(y)
                x{i}=nanmean(x{i});
                y{i}=nanmean(y{i});
            end
        end
        if showpoints==2 % replace y by means
            ystd = cell(length(y),1);
            for i=1:length(y)
                if length(x{i})~=length(y{i})
                    errormsg(['Unequal number of x and y values for set ' num2str(i)]);
                    if ishandle(h.fig)
                        close(h.fig);
                    end
                    return
                end
                
                ind=find(~isnan(x{i})&~isnan(y{i}));
                x{i}=x{i}(ind);
                y{i}=y{i}(ind);
                [x{i},ind]=sort(x{i});
                y{i}=y{i}(ind);
                uniqx=uniq(x{i});
                uniqy=zeros(1,length(uniqx));
                uniqystd=zeros(1,length(uniqx));
                
                if ~isempty(merge_x)
                    dx = diff(uniqx)/(uniqx(end)-uniqx(1));
                    ind = find(dx<merge_x);
                    for j = ind
                        x{i}(x{i}==uniqx(j)) = uniqx(j+1);
                    end
                end
                
                %logmsg('Next routine throws away values. Not ideal!');
                
                for j=1:length(uniqx)
                    if sum(x{i}==uniqx(j))> length(y{i})/length(uniqx)*0
                        uniqy(j) = nanmean(y{i}(x{i}==uniqx(j)));
                        switch errorbars
                            case 'sem'
                                uniqystd(j) = nansem(y{i}(x{i}==uniqx(j)));
                            otherwise
                                uniqystd(j) = nanstd(y{i}(x{i}==uniqx(j)));
                        end
                        pointsy{i}{j} = (y{i}(x{i}==uniqx(j)));   % for significance calculations
                    else
                        uniqy(j) = nan;
                        uniqystd(j) = nan;
                    end
                end
                ind = find(~isnan(uniqy));
                x{i} = uniqx(ind);
                y{i} = uniqy(ind);
                ystd{i} = uniqystd(ind);
            end
            if strcmp(errorbars,'sem')
                errorbars = 'std'; % to avoid trouble later when plotting
            end
        end
        
        if exist('smoothing','var') && smoothing>0
            for i=1:length(y)
                y{i}=smooth(y{i},smoothing);
                y{i}=y{i}(:)';
            end
        end
        
        % plot errors
        if ~exist('errorbars_sides','var')
            errorbars_sides='both';
        end
        if strcmp(errorbars,'sem')
            logmsg('Errorbars sem are not implemented for xy graph.');
            errorbars='none';
        end
        if ~isempty(ystd) && strcmp(errorbars,'none')~=1
            for i=1:length(y)
                if iscell(errorbars_sides)
                    ebsides = errorbars_sides{i};
                else
                    ebsides = errorbars_sides;
                end
                h.errorbar(i) = plot_errorbars({y{i}},x{i},{ystd{i}},[],y{i},...
                    errorbars,ebsides,errorbars_tick,color);
                if ishandle(h.errorbar(i)) || ~isnan(h.errorbar(i))
                    set(h.errorbar(i),'color',color{i},'clipping','off');
                end
            end
        end
        
        % plot significances
        % assume points of same x have to be compared across groups
        if exist('pointsy','var') && ( (length(x)==1) || (length(x{1})==length(x{2}) && all(x{1}==x{2})))
            for k=1:length(x{1}) % to have number of x-values
                for i=1:length(pointsy)
                    for j=i+1:length(pointsy)
                        try
                            htemp = compute_significances(...
                                {pointsy{i}{k},pointsy{j}{k}},...
                                x{1}(k)*ones(1,length(pointsy)),test,signif_y,...
                                [],[],tail,transform,[],correction,normalitytest,wingtipheight);
                            h.h_sig{i,j} = htemp.h_sig{2};
                            h.p_sig{i,j} = htemp.p_sig{2};
                        catch me
                            logmsg(['Problem computing significances: ' me.message]);
                            h.h_sig{i,j} = NaN;
                            h.p_sig{i,j} = NaN;                            
                        end
                        if h.h_sig{i,j}==1
                            logmsg(['Differences at x=' num2str(x{j}(k),2)...
                                ' are significant. p=' num2str(h.p_sig{i,j},2)  ]);
                        end
                    end
                end
            end
        end
        
        % line fit (do before plotting points)
        if exist('fit','var') || exist('slidingwindow','var')
            if ~exist('fit','var')
                fit = '';
            end
            if ~isempty(strfind(fit,'together')) %#ok<*STREMP>
                % make one fit for all groups together
                rx={[x{:}]};
                ry={[y{:}]};
            else
                % make fits for each groups separately
                rx=x;
                ry=y;
            end
            % plot points (twice to get the axis right)
            for i=1:length(y)
                if any(size(x{i})~=size(y{i}))
                    logmsg(['X and Y of series ' num2str(i) ' are not of equal size. Not plotting.']);
                    h.points(i) = nan;
                    continue
                end
                h.points(i) = plot(x{i},y{i},'o');
                set(h.points(i),'color',color{i},'clipping','off');
                set(h.points(i),'marker','none');
            end
            fity = {};fity{length(ry)}=[];
            ax = axis;
            fitx = linspace(ax(1)-5*(ax(2)-ax(1)),ax(1)+5*(ax(2)-ax(1)),1000);
            
            switch fit
                case ''
                    % do nothing
                case {'proportional','proportional_together'}
                    for i=1:length(ry)
                        rc=nanmean(ry{i})/nanmean(rx{i});
                        fity{i}=rc*fitx;
                        logmsg([' Proportionality: rc = ' num2str(rc)  ]);
                        [rcoef,~,p,t,df] = nancorrcoef(rx{i},ry{i});
                        logmsg(['   correlation coeff = ' num2str(rcoef) ...
                            ' , p = ' num2str(p) ' , df = ' num2str(df) ...
                            ' , t = ' num2str(t) ' (chi-squared test)']);
                    end
                case {'linear','linear_together'}
                    for i=1:length(ry)
                        if length(rx{i})~=length(ry{i})
                            errormsg('Cannot do a fit, because number of elements of x and y are unequal');
                            fity{i} = [];
                            continue
                        end
                        rc=nancov(rx{i},ry{i})/nancov(rx{i});
                        rc=rc(1,2);
                        offset=nanmean(ry{i})-rc*nanmean(rx{i});
                        fity{i}=rc*fitx+offset;
                        logmsg(['fit: rc = ' num2str(rc) ', offset = ' num2str(offset) ]);
                        [rcoef,~,p,t,df] = nancorrcoef(rx{i},ry{i});
                        logmsg(['   correlation coeff = ' num2str(rcoef) ...
                            ' , p = ' num2str(p) ' , df = ' num2str(df) ...
                            ' , t = ' num2str(t) ' (chi-squared test)']);
                    end
                case 'exponential'
                    for i=1:length(ry)
                        [tau,r]=fit_exponential(rx{i},ry{i});
                        fity{i}=r*exp(fitx/tau);
                        logmsg([' fit: exponential r = ' num2str(r) ', tau = ' num2str(tau) ]);
                    end
                case 'powerlaw'
                    for i=1:length(ry)
                        [exponent,r]=fit_powerlaw(rx{i},ry{i});
                        fity{i}=r*fitx.^exponent;
                        logmsg([' fit: powerlaw r = ' num2str(r) ', exponent = ' num2str(exponent) ]);
                    end
                case 'spline'
                    for i=1:length(ry)
                        fity{i}=spline( rx{i},ry{i}, fitx);
                    end
                case {'thresholdlinear','threshold_linear'}
                    for i=1:length(ry)
                        [rc, offset]=fit_thresholdlinear(rx{i},ry{i});
                        fity{i}=thresholdlinear(rc*fitx+offset);
                        logmsg([' fit: thresholdlinear rc = ' num2str(rc) ', offset = ' num2str(offset) ]);
                    end
                case {'nakarushton','naka_rushton'}
                    fitx = fitx(fitx>0);
                    if max(rx{1})>1
                        fitx = fitx/100;
                        rescale_to_1 = true;
                    else
                        rescale_to_1 = false;
                    end
                    for i=1:length(ry)
                        
                        c = rx{i}(~isnan(rx{i}));
                        r = ry{i}(~isnan(rx{i}));
                        
                        [nk_rm,nk_b,nk_n] = naka_rushton(c,r);
                        fity{i} = nk_rm* (fitx.^nk_n)./ ...
                            (nk_b^nk_n+fitx.^nk_n) ;
                        
                    end
                    if rescale_to_1
                        fitx = fitx*100;
                    end
                case 'dog'
                    for i = 1:length(ry)
                        par = dog_fit(rx{i},ry{i});
                        fity{i} = dog(par,fitx);
                        logmsg([' fit: dog par = ' num2str(par)  ]);
                    end
                case 'dog_zerobaseline'
                    for i=1:length(ry)
                        par = dog_fit(rx{i},ry{i},'zerobaseline');
                        fity{i} = dog(par,fitx);
                        logmsg([' fit: dog par = ' num2str(par)  ]);
                    end
                otherwise
                    logmsg([' Fit type ' fit ' is not implemented.']);
                    fit = '';
            end
            if ~isempty(fit)
                for i=1:length(ry)
                    if ~isempty(fity{i})
                        h.fit(i) = plot(fitx,fity{i},'-');
                        set(h.fit(i),'Color',color{i});
                    end
                end
                axis(ax);
                
            end
            
            if exist('slidingwindow','var')
                slidingwindow = str2double( slidingwindow );
                for i=1:length(ry)
                    stepsize = (max(rx{i})-min(rx{i}))/100;
                    [fity,fitx] = slidingwindowfunc( rx{i},ry{i}, ...
                        min(rx{i})-slidingwindow,stepsize,...
                        max(rx{i})+slidingwindow,...
                        slidingwindow,'nanmean',0);
                    
                    h.fit(i)=plot(fitx,fity,'-');
                    set(h.fit(i),'Color',color{i});
                end
                axis(ax);
            end
        end
        % plot points
        for i=1:length(y)
            if ~ishandle(h.points(i)) %&& isnan(h.points(i))
                continue
            end
            delete(h.points(i))
            if markersize>0
                h.points(i)=plot(x{i},y{i},'o');
                set(h.points(i),'markersize',markersize);
            else
                h.points(i)=plot(x{i},y{i},'.');
            end
            set(h.points(i),'color',color{i});
            if exist('linestyles','var') && ~isempty(linestyles)
                if ~iscell(linestyles)
                    linestyle = linestyles;
                else
                    linestyle = linestyle{i};
                end
                set(h.points(i),'linestyle',linestyle);
                
            end
            set(h.points(i),'linewidth',linewidth);
            
            if exist('markers','var')
                if ~iscell(markers)
                    marker = markers;
                else
                    marker = markers{i};
                end
                switch marker
                    case 'none'
                        set(h.points(i),'marker','none');
                    case 'open_triangle'
                        set(h.points(i),'marker','^');
                        set(h.points(i),'markerfacecolor',[1 1 1]);
                    case 'closed_triangle'
                        set(h.points(i),'marker','^');
                        set(h.points(i),'markerfacecolor',color{i});
                    case 'open_circle'
                        set(h.points(i),'marker','o');
                        % set(h.points(i),'markerfacecolor',[1 1 1]);
                        hm = h.points(i).MarkerHandle;
                        if ~isempty(hm)
                            hm.FaceColorData=uint8([255; 255; 255; 255]);
                        end
                    case 'closed_circle'
                        set(h.points(i),'marker','o');
                        set(h.points(i),'markerfacecolor',color{i});
                    otherwise
                        logmsg(['Unknown marker ' marker]);
                end
            end
        end
        
    otherwise
        errormsg(['graph style ' style ' is not implemented']);
        return
end

% set ylabel
if ~isempty(ylab)
    ylabel(ylab,'FontSize',fontsize,'FontName',fontname);
end

% set xlabel
if ~isempty(ylab)
    xlabel(xlab,'FontSize',fontsize,'FontName',fontname);
end

% adapt axis to prefax
if ~isempty(prefax)
    if length(prefax)==4
        axis(prefax);
    else
        ax=axis;
        ax([3 4])=prefax;
        axis(ax);
    end
end

switch style
    case {'bar','box'}
        % add bottomline
        switch bottomline
            case 'none'
                set(gca,'xcolor',[1 1 1])
            otherwise
                ax = axis;
                line([ ax(1) ax(2)],[ax(3) ax(3)],'Color','k');
        end
end

% set xticklabels
if ~isempty(xticklabels)
    set(gca,'XTick',[]);
    rotate_xticklabels = str2double(rotate_xticklabels);
    ax=axis;
    if ~iscell(xticklabels)
        xtc = cell(size(xticklabels,1),1);
        for i = 1:size(xticklabels,1)
            xtc{i} = xticklabels(i,:);
        end
        xticklabels = xtc;
        clear('xtc');
    end
    n_xtlabels=length(xticklabels);
    for s=1:n_xtlabels
        hl=text( x(s),ax(3)-(ax(4)-ax(3))/50, xticklabels{s},'FontName',fontname,'FontSize',fontsize);
        if rotate_xticklabels>0
            set(hl,'Rotation',rotate_xticklabels);
            set(hl,'HorizontalAlignment','right');
            set(hl,'VerticalAlignment','middle');
            set(hl,'FontSize',ceil(9-n_xtlabels/6));
        else
            set(hl,'HorizontalAlignment','center');
            set(hl,'VerticalAlignment','top');
        end
        
    end
end

if ~isempty(extra_code)
    %evaluate_extra_code(extra_code);
    child = get(gca,'children'); %#ok<NASGU> % to be used in extra_code
    try
        eval(extra_code); % do evaluation here to allow access to local variables
    catch me
        errormsg(['Problem in extra code: ' extra_code]);
        logmsg(me.message)
        %rethrow(me);
    end
end

if exist('legnd','var') && ~isempty(legnd)
    legnd = strtrim(legnd);
    legnd(legnd==';')=',';
    switch style
        case 'xy'
            handle = 'h.points,';
        case {'bar','box'}
            handle = '[h.bar{:}],';
        case 'cumul'
            handle = 'h.cumul,';
        case 'stackedbar'
            handle = 'h.stackedbar,' ;
        case 'pie'
            handle = 'h.pie,' ;
    end
    
    eval(['legend(' handle legnd(2:end-1) ')']);
    legend boxoff
end

if ~isempty(save_as)
    h.filename = save_figure(save_as);
end

return




function h = plot_errorbars(y,x,ystd,ny,means,errorbars,sides,tick,colors,width,marker)
if nargin<11 || isempty(marker)
    marker = '.';
end
if nargin<10 || isempty(width)
    switch sides
        case 'topline'
            width = 2;
        otherwise
            width = 0.5;
    end
end
if nargin<9 || isempty(colors)
    colors = [];
end
if nargin<8 || isempty(tick)
    tick = [];
end
if nargin<7 || isempty(sides)
    sides='away';
end
if nargin<6 || isempty(errorbars)
    errorbars = 'std';
end

h = {};
switch errorbars
    case 'none'
    otherwise
        dy = cell(length(y),1);
        switch errorbars
            case 'sem'
                if length(flatten(y))~=length(y) %isempty(ystd)
                    for i=1:length(y)
                        dy{i} = sem(y{i});
                    end
                elseif ~isempty(ystd)
                    for i=1:length(y)
                        dy{i} = ystd{i}/sqrt(ny{i});
                    end
                else
                    for i=1:length(y)
                        dy{i} = sem(y{i});
                    end
                end
            case 'std'
                if isempty(ystd)
                    for i = 1:length(y)
                        dy{i} = nanstd(y{i});
                    end
                else
                    dy = ystd;
                end
            case 'bootstrapmean'
                for i=1:length(y)
                    if ~isempty(y{i})
                        n = ceil(100000/length(y{i}));
                        dy{i}=std(bootstrp(n,@mean,y{i}));
                    else
                        dy{i} = [];
                    end
                end
            case 'bootstrapmedian'
                for i=1:length(y)
                    if ~isempty(y{i})
                        n = ceil(100000/length(y{i}));
                        dy{i}=std(bootstrp(n,@median,y{i}));
                    else
                        dy{i} = [];
                    end
                end
            otherwise
                errormsg(['Errorbars ' errorbars ' is not implemented']);
                return
        end
        dyeb=[dy{:}];
        
        if any(size(x)~=size(means))
            logmsg('X and MEANS are of unequal sizes. Cannot draw errorbars.');
            h = nan;
            return
        end
        switch sides
            case 'away'
                nonneg_dyeb=double(means>=0).*dyeb;
                neg_dyeb=double(means<0).*dyeb;
                h{1}=errorbar(x,means,0*dyeb,nonneg_dyeb,'k.');
                h{1}.Marker = marker;
                h{1}.LineWidth = width;
                h{2}=errorbar(x,means,neg_dyeb,0*dyeb,'k.');
                h{2}.Marker = marker;
                h{2}.LineWidth = width;
            case 'both'
                h = errorbar(x,means,dyeb,dyeb,'k.');
                h.Marker = marker;
                h.LineWidth = width;
            case 'below'
                h=errorbar(x,means,dyeb,0*dyeb,'k.');
                h.Marker = marker;
                h.LineWidth = width;
            case 'above'
                h=errorbar(x,means,0*dyeb,dyeb,'k.');
                h.Marker = marker;
                h.LineWidth = width;
            case 'none'
                h=errorbar(x,means,0*dyeb,0*dyeb,'k.');
                h.Marker = marker;
                h.LineWidth = width;
            case  'topline'
                for i=1:length(x)
                    if means(i)<0
                        dyeb(i) = -dyeb(i);
                    end
                    plot([x(i) x(i)],[means(i) means(i)+dyeb(i)],'-','linewidth',width,'color',colors{i});
                end
        end
end

if ~isempty(tick)
    if ~iscell(h)
        errorbar_tick(h,1/tick);
    else
        for i=1:length(h)
            errorbar_tick(h{i},1/tick);
        end
    end
end
return



