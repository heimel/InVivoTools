function [gy,gx,p,filename,h]=groupgraph(groups,measures,varargin)
%GROUPGRAPH
%
%  [GY,GX,P,FILENAME,H] = GROUPGRAPH(GROUPS,MEASURES,VARARGIN);
%
%
% 2007-2015, Alexander Heimel

global values_x values_y

gy = {};
gx = {};
p = [];
h = [];

path=''; % to overload matlab-function PATH
color=[]; % to overload matlab-function COLOR

% possible varargins with default values
pos_args={...  %  'reliable',1,...  % 1 to only use reliable records, 0 to use all
    'criteria',[],...
    'testdb',[],...
    'mousedb',[],...  % if empty, will use load_mousedb
    'groupdb',[],...
    'verbose',1,...
    'showpoints',1,...
    'test','',... % ttest',...
    'color',0.7*[1 1 1],...
    'spaced',1,...
    'errorbars','sem',...
    'save_option',1,...
    'signif_y',[],...
    'prefax',[],...
    'grouplabels',[],...
    'measurelabels',[],...
    'style','bar',...
    'extra_options','',...
    'extra_code','',...
    'filename','',...
    'name','',...
    'path','',...
    'value_per','measurement',... % changed 2012-06-22 from 'mouse'
    'xlab','',...
    'ylab','',...
    'min_n',1,...
    'markersize',10,...
    'group_by','group',...
    'legnd','',...
    'depth',[],...
    'add2graph_handle','',...
    'limit','',...
    'empty_group_spacing',1,...
};

if nargin<3
    logmsg('Using default arguments:');
    disp(pos_args)
end

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
    if rem(nvarargin,2)==1
        errormsg('Odd number of varguments');
        return
    end
    for i=1:2:nvarargin
        found_arg=0;
        for j=1:2:length(pos_args)
            if strcmp(varargin{i},pos_args{j})==1
                found_arg=1;
                if ~isempty(varargin{i+1}) % only assign if not-empty
                    assign(pos_args{j}, varargin{i+1});
                end
            end
        end
        if ~found_arg
            errormsg(['Could not parse argument ' varargin{i}]);
            return
        end
    end
end

% parse extra options
if ischar(extra_options)
    if ~isempty(limit)
        if ~isempty(extra_options)
            extra_options = [extra_options ','];
        end
        extra_options = [extra_options 'limit,{' limit '}'];
    end
    
    extra_options=split(extra_options,',',true);
end
if mod(length(extra_options),2)==1
    errormsg('Extra_options has an odd number of arguments. It should contain key, parameter pairs.');
    return
end

if length(unique(extra_options(1:2:end)))~=length(extra_options(1:2:end))
    errormsg('Some extra options appear twice.');
    return
end

for i=1:2:length(extra_options)
    try
    assign(strtrim(extra_options{i}),extra_options{i+1});
    catch me
        switch me.identifier
            case 'MATLAB:assigninInvalidVariable'
                errormsg(['''' extra_options{i} ''' is not a valid extra option.'])
                return
        end
        rethrow(me);
    end
end


if ischar(empty_group_spacing)
  empty_group_spacing = str2double(empty_group_spacing);
end

logmsg(['Collecting data for figure ' name ]);

if isempty(mousedb)
    mousedb = load_mousedb;
end

if isempty(groups)
    errormsg('No groups specified.');
    return
end

if exist('collect_records','var')
    collect_records = eval(collect_records); 
else
    collect_records = false;
end

% LEVELT LAB SPECIFIC SHOULD GO SOMEWHERE ELSE
if ~iscell(groups)
    bxdshift=0;
    if strcmp(strtrim(groups),'BXD* shift')==1
        bxdshift=1;
    elseif strcmp(strtrim(groups),'BXD* relative shift')==1
        bxdshift=2;
    end
    if bxdshift>0
        groupdb=load_groupdb;
        ind_md=find_record(groupdb,'name~BXD*md');
        ind_ctl=find_record(groupdb,'name~BXD*control');
        if length(ind_md)~=length(ind_ctl)
            error('unequal number of control and deprived BxD strains.');
        end
        operators='-/';
        op=operators(bxdshift);
        if bxdshift==2
            postop='';
        else
            postop='';
        end
        groups=['B6 MD 7d from p28' op 'B6 control 1 month ' postop ...
            ',D2 MD 7d from p28' op 'D2 control 1 month ' postop];
        grouplabels='B6,D2';
        for i=1:length(ind_md)
            if exist('exclude','var') && ~isempty(strfind(groupdb(ind_md(i)).name,'02'))
                continue
            end
            groups=[groups ',' groupdb(ind_md(i)).name op groupdb(ind_ctl(i)).name postop];
            grouplabels=[grouplabels ',' groupdb(ind_md(i)).name(4:5)];
        end
    end
end

% parse groups
if ~iscell(groups)
    groups=split(groups,',');
end
% check for group operators
groupoperators='-/+';
operator_groups=[];
group_operator=[];
allgroups={};
for g=1:length(groups)
    groups{g}=strtrim(groups{g});
    p=[];
    for go=groupoperators
        p=[p find(groups{g}==go)]; %#ok<*AGROW>
    end
    if isempty(p)
        allgroups{end+1}=groups{g};
        group_operator(end+1)=' ';
    elseif length(p)>1
        errormsg(['More than one operator (' groupoperators ') in a single group is not allowed.']);
        return
    else
        allgroups{end+1}=strtrim(groups{g}(1:p-1));
        allgroups{end+1}=strtrim(groups{g}(p+1:end));
        operator_groups(end+1)=length(allgroups)-1;
        group_operator(end+1)=groups{g}(p);
        group_operator(end+1)=' ';
    end
end
n_groups=length(allgroups);

if isempty(groupdb)
    groupdb=load_groupdb;
end
groups=[];
for g=1:n_groups
    ind_g=find_record(groupdb,['name~' allgroups{g}]);
    if ~isempty(ind_g)
        group=groupdb(ind_g);
    else
        % perhaps a whole filter
        filter = allgroups{g};
        ind_m=find_record(mousedb,filter);
        if isempty(ind_m)
            % perhaps a mouse number
            filter = ['mouse=' allgroups{g}];
            ind_m=find_record(mousedb,filter);
        end
        if isempty(ind_m)
            errormsg(['Cannot find group ' allgroups{g} '.']);
            return
        end
        group = groupdb([]); % to get structure
        group(1).name = allgroups{g};
        group(1).filter = filter;
        group(1).label = allgroups{g};
        group(1).combine = '';
    end
    groups=[groups group];
end
n_groups=length(groups); % it can be that multiple groups match group criteria

if collect_records
    collect_record(groups,'group');
end

% parse criteria
criteria = split(criteria,',',true);
n_criteria = length(criteria);

if ~isfield(groups,'criteria')
    groups(1).criteria = '';
end

if n_criteria>0
    count = 1;
    switch group_by
        case 'criteria'
            for c=1:n_criteria
                for g=1:n_groups
                    ngroups(count) = groups(g);
                    ngroups(count).criteria = criteria{c};
                    count = count+1;
                end
            end
        otherwise
            for g=1:n_groups
                for c=1:n_criteria
                    ngroups(count) = groups(g);
                    ngroups(count).criteria = criteria{c};
                    count = count+1;
                end
            end
    end
    groups = ngroups;
    n_groups = length(groups);
end

% parse filters
groupfilters = {};
for g=1:n_groups
    groupfilters{g} = group2filter(groups(g),groupdb,collect_records);
    if isempty(groupfilters{g})
        groupfilters{g} = ['strain=' groups(g).name];
    end
end

% parse grouplabels
if isempty(grouplabels)
    grouplabels = {};
    for g=1:n_groups
        grouplabels{g} = groups(g).label;
    end
elseif ~iscell(grouplabels)
    grouplabels = split(grouplabels,',');
end
grouplabels = shorten_bxdnames(grouplabels);

% collect results from databases
[r,dr,def_measurelabels] = get_compound_measurements(groups,measures,...
    'testdb',testdb,...
    'mousedb',mousedb,...
    'groupdb',groupdb,...  %    'reliable',reliable,...
    'value_per',value_per,...
    'extra_options',extra_options ...
    );
n_measures=length(r); % r{measures}{groups}[data]

if isempty(flatten(r))
    logmsg('No data');
    return
end

% parse colors
if ~iscell(color)
    tmpcolor=color;
    color={};
end
if n_groups>1
    use_color_for='groups';
    for g=1:n_groups
        if ~isfield(groups(g),'color') || isempty(groups(g).color) ||  ~isempty(color)
            color{g}=tmpcolor( mod(g-1,size(tmpcolor,1))+1 , :);
        else
            color{g}=groups(g).color;
        end
    end
else
    use_color_for='measures';
    for m=1:n_measures
        color{m}=tmpcolor( mod(m-1,size(tmpcolor,1))+1 , :);
    end
end
clear('tmpcolor');

if exist('set_value','var')
    set_value = eval(set_value);
    msr=set_value{1};
    if msr==-1
        msr=(1:n_measures);
    end
    grp=set_value{2};
    if grp==-1
        grp=(1:n_groups);
    end
    if grp==-2 % leave out even (for shift groups)
        grp=(2:2:n_groups);
    end
    
    for m=msr
        for g=grp
            r{m}{g}=set_value{3};
        end
    end
end

% for statistical tests on difference between compound groups:
% could later be  implemented in get_compound_measurements
r_std={};
r_n={};
for m=1:n_measures
    for g=1:length(r{m})
        r_std{m}{g}=nanstd(r{m}{g}(:));
        r_n{m}{g}=sum(~isnan(r{m}{g}(:)));
    end
end

% parse measurelabels
if isempty(measurelabels)
    measurelabels=def_measurelabels;
elseif ~iscell(measurelabels)
    measurelabels=split(measurelabels,',');
end

% center measurelabels for use in captions
wrong_number_labels = false;
switch style
    case 'surf'
        if length(measurelabels)==2
            measurelabels{3} = def_measurelabels{3};
        end
    otherwise
        if length(measurelabels)~=n_measures
            wrong_number_labels = true;
            expecting = n_measures;
        end
end
if wrong_number_labels
    errormsg(['Expecting ' num2str(expecting) ...
        ' or zero measure labels.'])
    return
end

% make difference of groups if necessary
if ~isempty(operator_groups)
    % first change values for group means
    % and save error information
    for m=1:n_measures
        for g=1:length(r{m})
            r{m}{g}=nanmean(r{m}{g});
        end
    end
    
    remove_groups=[];
    diff_r=r;
    diff_r_std={};
    diff_r_n={};
    for og=operator_groups
        remove_groups(og+1)=1;
        for m=1:length(measurelabels)
            eval(['diff_r{m}{og}=r{m}{og}' group_operator(og) 'r{m}{og+1};']);
            switch group_operator(og)
                case {'+','-'}
                    diff_r_std{m}{og}=sqrt(r_std{m}{og}^2+r_std{m}{og+1}^2);
                    diff_r_n{m}{og}=(r_n{m}{og}+r_n{m}{og+1})/2; % for degrees of freedom
                case '*'
                    diff_r_std{m}{og}=sqrt( (r_std{m}{og}*r{m}{og+1})^2 ...
                        + (r_std{m}{og+1}*r{m}{og})^2 );
                    diff_r_n{m}{og}=(r_n{m}{og}+r_n{m}{og+1})/2; % for degrees of freedom
                case '/'
                    diff_r_std{m}{og}=sqrt( (r_std{m}{og}/r{m}{og+1})^2 + ...
                        (r_std{m}{og+1}*r{m}{og}/(r{m}{og+1})^2)^2);
                    diff_r_n{m}{og}=(r_n{m}{og}+r_n{m}{og+1})/2; % for degrees of freedom
                otherwise
                    logmsg(['Cannot compute sem for group operator ' group_operator(og)]);
                    diff_r_std{m}{og}=nan;
            end
        end
    end
    g=1;
    r={};
    r_std={};
    r_n={};
    for m=1:length(measurelabels)
        r{m}={};
        r_std{m}={};
        r_n{m}={};
    end
    while g<=length(diff_r{1})
        if ~remove_groups(g)
            for m=1:length(measurelabels)
                r{m}{end+1}=diff_r{m}{g};
                r_std{m}{end+1}=diff_r_std{m}{g};
                r_n{m}{end+1}=diff_r_n{m}{g};
            end
        end
        g=g+1;
    end
    
    newgrouplabels={};
    if length(grouplabels)==n_groups % i.e. labels are for all groups
        g=1;
        while g<=n_groups
            if ~remove_groups(g)
                newgrouplabels{end+1}=grouplabels{g};
            else
                newgrouplabels{end}=[newgrouplabels{end} group_operator(g) grouplabels{g}];
            end
            g=g+1;
        end
        grouplabels=newgrouplabels;
    end
    
    if strcmp(use_color_for,'groups')
        newcolor={};
        g=1;
        while g<=n_groups
            if ~remove_groups(g)
                newcolor{end+1}=color{g};
            end
            g=g+1;
        end
        color=newcolor;
    end
    
    n_groups=length(r{1});
end

% center grouplabels for use in captions
grouplabels=strjust(char(grouplabels),'center');
switch style
    case 'xy'
        if size(grouplabels,1)>n_groups*n_measures/2
            errormsg(['Wrong number of grouplabels. ' ...
                num2str(size(grouplabels,1)) ' given, ' num2str(n_groups*n_measures/2) ' expected.' ]);
            logmsg(grouplabels)
            return
        elseif size(grouplabels,1)<n_groups*n_measures/2
            logmsg(['Wrong number of grouplabels. ' ...
                num2str(size(grouplabels,1)) ' given, ' num2str(n_groups*n_measures/2) ' expected.' ]);
            logmsg(grouplabels)
            for i=size(grouplabels,1)+1:n_groups*n_measures/2
                % grouplabels{i} = '';
                grouplabels(i,:) = ' ';
            end
        end
    otherwise
        if size(grouplabels,1)~=n_groups
            errormsg(['Wrong number of grouplabels. ' ...
                num2str(size(grouplabels,1)) ' given, ' num2str(n_groups) ' expected.' ]);
            logmsg(cellstr(grouplabels));
%            return
        end
end


% assign figure filename
l = grouplabels(:)';
m = measurelabels;
if isempty(filename)
    if isempty(name)
        filename = ['pop_' l(1:min(end,15)) '_' m{:} ];
    else
        filename = name;
    end
end

if n_measures==1
    group_by = 'measure';
end

% call graph
glabel = {};
ny = {};
ystd = {};
gz = {};
switch style
    case 'surf'
        if mod(length(r),3)~=0 % i.e. even number of measures
            errormsg('Number of measures should be multiple of 3 for surface plot.');
            return
        end
        seriescount=1;
        for g=1:n_groups
            for m=1:3:length(r)
                if sum(~isnan(r{m}{g}))>0 && sum(~isnan(r{m+1}{g}))>0
                    gx{seriescount}=r{m}{g};
                    gy{seriescount}=r{m+1}{g};
                    gz{seriescount}=r{m+2}{g};
                    glabel{seriescount}=grouplabels(g,:);
                    switch use_color_for
                        case 'groups'
                            gcolor{seriescount}=color{g};
                        case 'measures'
                            gcolor{seriescount}=color{seriescount};
                    end
                    seriescount=seriescount+1;
                end
            end
        end
        
        xlab=measurelabels{1};
        ylab=measurelabels{2};
        xticklabels='';
    case 'xy'
        if mod(length(r),2)==0 % i.e. even number of measures
            % odd measures will be on x-axis
            % even measures will be on y-axis
            seriescount=1;
            for g=1:n_groups
                for m=1:2:length(r)
                    if sum(~isnan(r{m}{g}))>0 && sum(~isnan(r{m+1}{g}))>0
                        gx{seriescount}=r{m}{g};
                        gy{seriescount}=r{m+1}{g};
                        if showpoints==1
                            logmsg('Using measurement errors for error bars');
                            ystd{seriescount}=dr{m+1}{g};
                        end
                        glabel{seriescount}=grouplabels(g,:);
                        switch use_color_for
                            case 'groups'
                                gcolor{seriescount}=color{g};
                            case 'measures'
                                gcolor{seriescount}=color{seriescount};
                        end
                        seriescount=seriescount+1;
                    end
                end
            end
            
            xlab=measurelabels{1};
            ylab=measurelabels{2};
            xticklabels='';
        elseif length(r)==1 && mod(length(r{1}),2)==0 % i.e. even # groups, 1 measure
            for g=1:n_groups/2
                gx{g}=r{1}{g};
                gy{g}=r{1}{n_groups/2+g};
                gcolor{g}=color{g};
            end
            xticklabels='';
            xlab=grouplabels(1,:);
            if size(grouplabels,1)>1
                ylab=grouplabels(2,:);
            else
                ylab = '';
            end
        end
    otherwise % eg {'bars','bar','box','cumul','hist','rose'}
        switch group_by
            case 'group'
                inc_xt_group=n_measures+1;
                inc_xt_measure=1;
            case 'measure'
                inc_xt_group=1;
                inc_xt_measure=n_groups+1;
        end
        n_measures=length(r);
        for m=1:n_measures
            xt=1+(m-1)*inc_xt_measure;
            barcount=1;
            for g=1:n_groups
                if sum( ~isnan(r{m}{g}) )>0
                    gx{m}(barcount)=xt;
                    gy{m}{barcount}=r{m}{g};
                    if ~isempty(r_std)
                        ystd{m}{barcount}=r_std{m}{g};
                    end
                    if ~isempty(r_n)
                        ny{m}{barcount}=r_n{m}{g};
                    end
                    switch group_by
                        case 'group'
                            glabel{m}{barcount}=measurelabels{m};
                            if strcmp(use_color_for,'groups')
                                gcolor{m}{barcount}=color{g};
                            else
                                gcolor{m}{barcount}=color{m};
                            end
                            
                        case 'measure'
                            glabel{m}{barcount}=grouplabels(g,:);
                            gcolor{m}{barcount}=color{g};
                    end
                    barcount=barcount+1;
                    xt=xt+inc_xt_group;
                elseif isempty(strtrim(grouplabels(g,:))) || n_measures>1
                    xt=xt+inc_xt_group*empty_group_spacing;
                else
                    logmsg(['Less than ' num2str(min_n) ...
                        ' points in group [' grouplabels(g,:) ']']);
                end
            end
        end
        switch style
            case {'cumul'}
                if n_measures==1
                    xlab=measurelabels{1}; % take first and only measurelabel
                end
                if isempty(ylab)
                    ylab='Cumulative probability';
                end
                xticklabels={};
            case {'hist'}
                if n_measures==1
                    xlab=measurelabels{1}; % take first and only measurelabel
                end
                if isempty(ylab)
                    ylab='Count';
                end
                xticklabels={};
            otherwise
                if n_measures==1 && isempty(ylab)
                    ylab=measurelabels{1}; % take first and only measurelabel
                end
                xticklabels=glabel;
        end
end

if exist('xmanual','var')
    gx = eval(xmanual);
end

% legend
if ~isempty(strfind(lower(legnd),'on')) %#ok<*NODEF> %i.e. 'on' or 'location'
    if strcmpi(strtrim(legnd),'on')
        legnd = {};
    else
        legnd = eval(legnd);
        legnd = {legnd{:}};
    end
    for g=1:size(grouplabels,1)
        legnd{end+1} = strtrim(grouplabels(g,:));
    end
    legnd = cell2str(legnd);
    ind = strmatch('legnd',extra_options);
    extra_options{ind+1} = legnd;
end

if ~exist('gy','var') || isempty(gy)
    logmsg('No data. Check if mice are present in mouse_db (or use ''add_missing_mice'' to add them). Or try to remove limits.');
    return
end

if isempty(add2graph_handle)
    figure('color',[1 1 1]);
    axishandle = gca;
elseif ishandle(add2graph_handle)
    axishandle = add2graph_handle;
else
    errormsg('Could not add to requested graph.');
    return
end

h = ivt_graph(gy,gx,...
    'ylab',ylab,...
    'xlab',xlab,...
    'axishandle',gca,... % seems it should be axishandle
    'style',style,...
    'xticklabels',xticklabels,...
    'prefax',prefax,'errorbars',errorbars,...
    'signif_y',signif_y,'spaced',spaced,'color',gcolor,...
    'test',test,'showpoints',showpoints,'extra_options',extra_options,...
    'extra_code',extra_code,'ystd',ystd,'ny',ny,'z',gz);


if isfield(h,'p_sig')
    p=h.p_sig;
else
    p=[];
end

if exist('name','var') && ~isempty(name)  && ishandle(h.fig)
    set(h.fig,'Name',capitalize(name),'NumberTItle','off');
end

if save_option
    filename = save_figure(filename,path);
end

values_x = gx;
values_y = gy;

if length(values_y)==1 && iscell(values_y{1})
    values_y = values_y{1};
end
if length(values_x)==1 && iscell(values_x{1})
    values_x = values_x{1};
end

evalin('base','global values_x values_y');
logmsg('Values available in workspace as values_x values_y. To show data: dispcell(values_y)');
