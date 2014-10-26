function h=graph(y,x,varargin)
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
%     'test',{['ttest'],'kruskal_wallis_test'}
%     'spaced',{[0],1}    % spacing points in bar plot
%     'color',0.7*[1 1 1]
%     'errorbars','sem'
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
%     'fontsize',[20]
%     'fontname',['arial']
%     'linestyles',''
%     'linewidth',[3]
%     'ystd',[]
%     'ny',[]
%     'bins',[]  % for (cumulative) histogram and rose
%     'tail','both'   % for significance tests
%     'legnd',''  % legend,example legnd,{wt,t1}
%     'save_as',''
%     'z',{}
%     'extra_options',''
%
%  EXTRA_OPTIONS is a comma-separated string containing option and value
%        sort_y,asc or dec, sorts wrt y-values ascending or descending
%        min_n, # , where # is the minimal number of y-values to include a
%                           group in the graph
%        fit, linear
%
%
% 2006-2014, Alexander Heimel
%

h=[];
if nargin<2
    x=[];
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
    'showpoints',1,...
    'test','',... %'ttest',...
    'spaced',1,...
    'color',0.7*[1 1 1],...
    'errorbars','sem',...
    'style',trim(char(double(length(x)==length(y))*'xy '+ ...
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
    'fontsize',20,...
    'fontname','arial',...
    'linestyles','',...
    'linewidth',3,...
    'ystd',[],...
    'ny',[],...
    'bins',[],... % for (cumulative) histogram and rose
    'tail','both',... % for significance tests
    'legnd','',...  % legend,example legnd,{wt,t1}
    'save_as','',...
    'z',{},...
    'smoothing',0,...
    'merge_x',[],...
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
    assign(trim(extra_options{i}),extra_options{i+1});
end

if exist('errorbars_sides','var')
    errorbars_sides=trim(errorbars_sides);
    if errorbars_sides(1)=='{'
        errorbars_sides=split( errorbars_sides(2:end-1),';');
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

if exist('markersize','var')
    if ischar(markersize)
        markersize = str2double(markersize);
    end
end

if exist('markers','var')
    markers=trim(markers);
    if markers(1)=='{'
        markers=split( markers(2:end-1),';');
    end
end
if exist('linestyles','var')
    linestyles=trim(linestyles);
    if ~isempty(linestyles) && linestyles(1)=='{'
        linestyles=split( linestyles(2:end-1),';');
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
    h.fig=figure;
else
    axes(axishandle);
    h.fig=get(gca,'parent');
end
h.p_sig={};
hold on;

if length(prefax)==4
    axis(prefax);
end

% reformat y into cell-structure
if ~iscell(y)
    if ~ismatrix(y)
        errormsg('Unable to handle arrays of more than 2 dimensions');
        return
    end
    old_y=y;
    y=cell(size(old_y,1),1);
    for i=1:size(old_y,1)
        y{i}=old_y(i,:);
    end
end

% flatten y,x,color
if iscell(y{1})
    orgy=y;
    n_measures=length(y);
    n_groups=length(y{1});
    y={};
    for i=1:n_measures
        y={y{:},orgy{i}{:}};
    end
    if iscell(x)
        orgx=x;
        x=[];
        for i=1:n_measures
            x=[x orgx{i}];
        end
    end
    if iscell(color)
        if iscell(color{1})
            orgcolor=color;
            color={};
            for i=1:n_measures
                color={color{:},orgcolor{i}{:}};
            end
        end
    end
    if ~isempty(ystd)
        if iscell(ystd)
            if iscell(ystd{1})
                orgystd=ystd;
                ystd={};
                for i=1:n_measures
                    ystd={ystd{:},orgystd{i}{:}};
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
    orgxticklabels=xticklabels;
    if ~isempty(xticklabels)
        xticklabels={};
        for i=1:n_measures
            xticklabels={xticklabels{:},orgxticklabels{i}{:}};
        end
    end
end



switch style
    case 'surf'
        logmsg('Surf currently only works for 1 image');
        
        n_x = size(z{1},2);
        n_y = size(z{1},1);
        % n_z = size(z{1},3);
        
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
        if exist('bins','var') && ~isempty(bins) && ischar(bins) %#ok<NODEF>
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
            if 0 % for friederike
                for i=1:length(y)
                    [rose_theta(i,:),rose_r(i,:)] = rose( y{i}+pi/bins,bins); %%%????
                    h.polar(i) = polar( rose_theta(i,:)-pi/bins, rose_r(i,:));
                    hold on
                    set(h.polar(i),'Color',color{i});
                end
            else
                for i=1:length(y)
                    %                     if max(bins>45) % i.e. probably degrees
                    %                         bins = bins/180*pi;
                    %                     end
                    
                    [rose_theta(i,:),rose_r(i,:)] = rose( y{i}+pi/bins,bins);
                    h.polar(i) = polar( rose_theta(i,:)-pi/bins, rose_r(i,:));
                    hold on
                    set(h.polar(i),'Color',color{i});
                end
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
            set(hh(1),'FaceColor',color{i});%,'EdgeColor','w')
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
        if length(x)>5
            p=get(gcf,'position');
            p(3)=p(3)*(length(x)/6)^0.5;
            set(gcf,'position',p);
        end
        width=min(0.6,0.2*length(x));
        left=0.5-width/2;
        subplot('position',[left 0.20 width 0.7]);
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
        end
        
        if exist('sort_y','var')
            switch sort_y
                case 'asc'
                    [means,ind]=sort(means);
                case 'desc'
                    [means,ind]=sort(-means);
                    means=-means;
                otherwise
                    disp(['sory_y by ' sort_y ' is not implemented yet']);
                    ind=(1:length(means));
            end
            y={y{ind}};
            color={color{ind}};
            xticklabels={xticklabels{ind}};
        end
        
        
        % plot errors
        if ~exist('errorbars_sides','var')
            errorbars_sides='away';
        end
        h.errorbar=plot_errorbars(y,x,ystd,ny,means,errorbars,errorbars_sides,errorbars_tick); %#ok<*NODEF>
        
        % plot bars
        if ~exist('nobars','var')
            for i=1:length(y)
                h.bar{i}=bar(x(i), means(i) );
                if iscell(color)
                    set(h.bar{i},'facecolor',color{i});
                else
                    set(h.bar{i},'facecolor',color);
                end
            end
        end
        
        % plot points
        if showpoints
            for i=1:length(y)
                plot_points(x(i),y{i},spaced);
            end
        end
        
        % plot significances
        h = compute_significances( y,x, test, signif_y, ystd, ny, tail, h );
        
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
            for i=1:length(y)
                if length(x{i})~=length(y{i})
                    msg = ['Unequal number of x and y values for set ' num2str(i)];
                    errordlg(msg,'Graph');
                    disp(['GRAPH: ' msg]);
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
                    dx = diff(uniqx)./uniqx(1:end-1);
                    ind = find(dx<merge_x);
                    for j = ind
                        x{i}(x{i}==uniqx(j)) = uniqx(j+1);
                    end
                end
                
                logmsg('Next routine throws away values. Not ideal!');
                
                for j=1:length(uniqx)
                    if sum(x{i}==uniqx(j))> length(y{i})/length(uniqx)*0;%*0.5;%0.5
                        uniqy(j) = nanmean(y{i}(x{i}==uniqx(j)));
                        uniqystd(j) = nansem(y{i}(x{i}==uniqx(j))); % notice SEM!
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
            logmsg('Errorbars sem are not implemented for xy graph');
            errorbars='std';
        end
        if ~isempty(ystd) && strcmp(errorbars,'none')~=1
            for i=1:length(y)
                if iscell(errorbars_sides)
                    ebsides=errorbars_sides{i};
                else
                    ebsides=errorbars_sides;
                end
                h.errorbar(i)=plot_errorbars({y{i}},x{i},{ystd{i}},[],y{i},...
                    errorbars,ebsides,errorbars_tick);
                if ~isnan(h.errorbar(i))
                    set(h.errorbar(i),'color',color{i},'clipping','off');
                end
            end
        end
        
        % plot significances
        % assume points of same x have to be compared across groups
        if exist('pointsy','var')
            for k=1:length(x{1}) % to have number of x-values
                for i=1:length(pointsy)
                    for j=i+1:length(pointsy)
                        try
                            [h.h_sig{i,j},h.p_sig{i,j},statistic,statistic_name,dof,test]=...
                                plot_significance(pointsy{i}{k},x{i}(k),...
                                pointsy{j}{k},x{j}(k),max([y{i}(k)+ystd{i}(k) y{j}(k)+ystd{j}(k)]),0,0,test);
                        catch
                            h.h_sig{i,j}=nan;
                            h.p_sig{i,j}=nan;
                            statistic = nan;
                            statistic_name = '';
                            dof=nan;
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
            if ~isempty(strfind(fit,'together'))
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
                h.points(i)=plot(x{i},y{i},'o');
                set(h.points(i),'color',color{i},'clipping','off');
                set(h.points(i),'marker','none');
            end
            fity={};fity{length(ry)}=[];
            ax=axis;
            fitx=linspace(ax(1)-5*(ax(2)-ax(1)),ax(1)+5*(ax(2)-ax(1)),1000);
            
            switch fit
                case ''
                    % do nothing
                case {'proportional','proportional_together'}
                    for i=1:length(ry)
                        rc=nanmean(ry{i})/nanmean(rx{i});
                        fity{i}=rc*fitx;
                        disp(['GRAPH: Proportionality: rc = ' num2str(rc)  ]);
                        [rcoef,n,p,t,df]=nancorrcoef(rx{i},ry{i});
                        disp(['GRAPH:   correlation coeff = ' num2str(rcoef) ...
                            ' , p = ' num2str(p) ' , df = ' num2str(df) ...
                            ' , t = ' num2str(t) ]);
                    end
                case {'linear','linear_together'}
                    for i=1:length(ry)
                        rc=nancov(rx{i},ry{i})/nancov(rx{i});
                        rc=rc(1,2);
                        offset=nanmean(ry{i})-rc*nanmean(rx{i});
                        fity{i}=rc*fitx+offset;
                        disp(['GRAPH: fit: rc = ' num2str(rc) ', offset = ' num2str(offset) ]);
                        [rcoef,n,p,t,df]=nancorrcoef(rx{i},ry{i});
                        disp(['GRAPH:   correlation coeff = ' num2str(rcoef) ...
                            ' , p = ' num2str(p) ' , df = ' num2str(df) ...
                            ' , t = ' num2str(t) ]);
                    end
                case 'exponential'
                    for i=1:length(ry)
                        [tau,r]=fit_exponential(rx{i},ry{i});
                        fity{i}=r*exp(fitx/tau);
                        disp(['GRAPH: fit: exponential r = ' num2str(r) ', tau = ' num2str(tau) ]);
                    end
                case 'powerlaw'
                    for i=1:length(ry)
                        [exponent,r]=fit_powerlaw(rx{i},ry{i});
                        fity{i}=r*fitx.^exponent;
                        disp(['GRAPH: fit: powerlaw r = ' num2str(r) ', exponent = ' num2str(exponent) ]);
                    end
                case 'spline'
                    for i=1:length(ry)
                        fity{i}=spline( rx{i},ry{i}, fitx);
                    end
                case {'thresholdlinear','threshold_linear'}
                    for i=1:length(ry)
                        [rc, offset]=fit_thresholdlinear(rx{i},ry{i});
                        fity{i}=thresholdlinear(rc*fitx+offset);
                        disp(['GRAPH: fit: thresholdlinear rc = ' num2str(rc) ', offset = ' num2str(offset) ]);
                    end
                case {'nakarushton','naka_rushton'}
                    fitx=fitx(fitx>0);
                    if max(rx{1})>1
                        fitx = fitx/100;
                        rescale_to_1 = true;
                    else
                        rescale_to_1 = false;
                    end
                    for i=1:length(ry)
                        % first fit proportional to get good seeding values
                        % rc=nanmean(ry{i})/nanmean(rx{i});
                        %						[nk_rm,nk_b,nk_n] = naka_rushton(rx{i},ry{i}, [ rc 0.57 1]);
                        
                        c=rx{i}(~isnan(rx{i}));
                        r=ry{i}(~isnan(rx{i}));
                        
                        [nk_rm,nk_b,nk_n] = naka_rushton(c,r);
                        fity{i}=nk_rm* (fitx.^nk_n)./ ...
                            (nk_b^nk_n+fitx.^nk_n) ;
                    end
                    if rescale_to_1
                        fitx = fitx*100;
                    end
                otherwise
                    disp(['GRAPH: Fit type ' fit ' is not implemented.']);
                    fit='';
            end
            if ~isempty(fit)
                for i=1:length(ry)
                    h.fit(i)=plot(fitx,fity{i},'-');
                    set(h.fit(i),'Color',color{i});
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
            if isnan(h.points(i))
                continue
            end
            delete(h.points(i))
            h.points(i)=plot(x{i},y{i},'o');
            set(h.points(i),'markersize',markersize);
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
                        set(h.points(i),'markerfacecolor',[1 1 1]);
                    case 'closed_circle'
                        set(h.points(i),'markerfacecolor',color{i});
                    otherwise
                        disp('WARNING: unknown marker');
                end
            end
        end
        
    otherwise
        error(['graph style ' style ' is not implemented']);
end


% set ylabel
if ~isempty(ylab)
    ylabel(ylab,'FontSize',fontsize,'FontName',fontname);
end

% set xlabel
if ~isempty(ylab)
    xlabel(xlab,'FontSize',fontsize,'FontName',fontname);
end

% set yticklabel
%set(gca,'yticklabel',get(gca,'yticklabel'),'fontsize',fontsize,'fontname',fontname)

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
        ax=axis;
        line([ ax(1) ax(2)],[ax(3) ax(3)],'Color','k');
end

% set xticklabels
if ~isempty(xticklabels)
    set(gca,'XTick',[]);
    rotate_xticklabels=str2double(rotate_xticklabels);
    ax=axis;
    if ~iscell(xticklabels)
        xtc= cell(size(xticklabels,1),1);
        for i=1:size(xticklabels,1)
            xtc{i}=xticklabels(i,:);
        end
        xticklabels=xtc;
        clear('xtc');
    end
    n_xtlabels=length(xticklabels);
    for s=1:n_xtlabels
        hl=text( x(s),ax(3)-(ax(4)-ax(3))/50, xticklabels{s},'FontName',fontname,'FontSize',fontsize);
        if rotate_xticklabels>45
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
    child=get(gca,'children'); %#ok<NASGU> % to be used in extra_code
    try
        eval(extra_code); % do evaluation here to allow access to local variables
    catch me
        errormsg(['Problem in extra code: ' extra_code]);
        %rethrow(me);
    end
end


% increase linewidth and fontsize for presentation
% has to stay after all changes are made to the figure
%bigger_linewidth(4);
%smaller_font(-14);

if exist('legnd','var') && ~isempty(legnd)
    legnd = trim(legnd);
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
    filename=save_figure(save_as);
end

return




function	h=plot_errorbars(y,x,ystd,ny,means,errorbars,sides,tick)
if nargin<8
    tick = [];
end

if nargin<7
    sides='away';
end
h={};
switch errorbars
    case 'none'
    case {'std','sem'}
        dy = cell(length(y),1);
        switch errorbars
            case 'sem'
                if length(flatten(y))~=length(y) %isempty(ystd)
                    for i=1:length(y)
                        dy{i}=sem(y{i});
                    end
                else
                    for i=1:length(y)
                        dy{i}=ystd{i}/sqrt(ny{i});
                    end
                end
            case 'std'
                if isempty(ystd)
                    for i=1:length(y)
                        dy{i}=nanstd(y{i});
                    end
                else
                    dy=ystd;
                end
        end
        dyeb=[dy{:}];
        
        if any(size(x)~=size(means))
            disp('GRAPH: X and MEANS are of unequal sizes. Cannot draw errorbars.');
            h = nan;
            return
        end
        
        switch sides
            case 'away'
                nonneg_dyeb=double(means>=0).*dyeb;
                neg_dyeb=double(means<0).*dyeb;
                h{1}=errorbar(x,means,0*dyeb,nonneg_dyeb,'k.');
                h{2}=errorbar(x,means,neg_dyeb,0*dyeb,'k.');
            case 'both'
                h=errorbar(x,means,dyeb,dyeb,'k.');
            case 'below'
                h=errorbar(x,means,dyeb,0*dyeb,'k.');
            case 'above'
                h=errorbar(x,means,0*dyeb,dyeb,'k.');
            case 'none'
                h=errorbar(x,means,0*dyeb,0*dyeb,'k.');
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



function h = compute_significances( y,x, test, signif_y, ystd, ny, tail, h)
if strcmp(test,'none')
    return
end

if  strcmp(test,'chi2')
    d = zeros(length(y),2);
    for i=1:length(y)
        d(i,1)=sum( y{i}(~isnan(y{i}))==0 );
        d(i,2)=sum( y{i}(~isnan(y{i}))==1 );
    end
    [p_chi2,chi2] = chi2class( d);
    logmsg(['p of chi2class test = ' num2str(p_chi2) ...
        ' over all groups. chi2-statistic = ' num2str(chi2)]);
end

ax=axis;
height=(ax(4)-ax(3))/20;
w=0.1;


if length(y)>2 % multigroup comparison
    v = [];
    group = [];
    for i=1:length(y)
        v = cat(1,v,y{i}(:));
        group = cat(1,group,i*ones(length(y{i}),1));
    end
    [h.p_groupkruskalwallis,anovatab,stats] = kruskalwallis(v,group,'off');
    logmsg(['Group kruskalwallis: p = ' num2str(h.p_groupkruskalwallis,2) ', df = ' num2str(anovatab{4,3})]);
    [h.p_groupanova,anovatab,stats] = anova1(v,group,'off');
    logmsg(['Group anova: p = ' num2str(h.p_groupanova,2) ', s[' num2str(stats.df) '] = ' num2str(stats.s)]);
end

if ~( length(signif_y)==1 && signif_y==0)
    for i=1:length(y)
        switch test
            case 'ttest'
                % check normality
                [h_norm,p_norm] = swtest(y{i});
                if h_norm
                    logmsg(['Group ' num2str(i) ' is not normal. Shapiro-Wilk test p = ' num2str(p_norm) '. Change test to kruskal_wallis']);
                end
            case 'paired_ttest'
                % check normality
                [h_norm,p_norm] = swtest(y{i});
                if h_norm
                    logmsg(['Group ' num2str(i) ' is not normal. Shapiro-Wilk test p = ' num2str(p_norm) '. Change test to signrank.']);
                end
        end
    end
    for i=1:length(y)
        for j=i+1:length(y)
            nsig=(i-1)*length(y)+j;
            
            ind_y=[];
            
            if ~isempty(signif_y)
                if size(signif_y,2)==1 % single column, specify which to do
                    if isempty(find(signif_y==nsig,1))
                        continue
                    end
                else % double column, specify height or which not to do
                    ind_y = find(signif_y(:,1)==nsig);
                    if ~isempty(ind_y) && isnan(signif_y(ind_y,2))
                        continue
                    end
                end
            end
            
            
            if isempty(ind_y) % no mention in signif_y list
                y_star=ax(4)+height*(j-i-1);
            else
                y_star=signif_y(ind_y(1),2);
            end
            
            % matlab significance test using sample data
            if iscell(ystd) && iscell(ny)
                [h.h_sig{i,j},h.p_sig{i,j},statistic,statistic_name,dof,testperformed]=...
                    plot_significance(y{i},x(i),y{j},x(j),y_star,height,w,test,...
                    ystd{i},ny{i},ystd{j},ny{j},tail);
            else
                [h.h_sig{i,j},h.p_sig{i,j},statistic,statistic_name,dof,testperformed]=...
                    plot_significance(y{i},x(i),y{j},x(j),y_star,height,w,test,...
                    [],[],[],[],tail);
            end
            if h.p_sig{i,j}<1
                outstat = ['Pairwise significance: ' num2str(nsig)...
                    ' = grp ' num2str(i) ' vs grp ' num2str(j) ...
                    ', p = ' num2str(h.p_sig{i,j},2) ...
                    ', ' testperformed ];
                if ~isempty(statistic_name)
                    if ~isempty(dof) && ~isnan(dof)
                        outstat = [outstat ...
                            ', ' statistic_name ...
                            '[' num2str(dof) '] = ' num2str(statistic) ]; %#ok<AGROW>
                    else
                        outstat = [outstat ...
                            ', ' statistic_name ' = ' num2str(statistic) ]; %#ok<AGROW>
                    end
                end
                logmsg(outstat);
            end
            
        end
    end
end

