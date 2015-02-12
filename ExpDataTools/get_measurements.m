function [results,dresults,measurelabel] = get_measurements( groups, measure, varargin )
%GET_MEASUREMENTS gets results for groups of mice for one or more measures
%
% [RESULTS,DRESULTS,MEASURELABELS] = GET_MEASUREMENTS( GROUPS, MEASURE,
% VARARGIN )
%
%    RESULTS has structure like RESULTS{ group }(measure)
%    RESULTS has structure like DRESULTS{ group }(measure) and contains
%       SEM in the individual measurements
%    MEASURELABEL is cell list of string
%
% 2007-2014, Alexander Heimel
%

persistent expdb_cache

results={};
dresults={};

pos_args={...
    'value_per','measurement',... % 'group','mouse','test','measurement', 'stack','neurite' %'reliable',1,...  % 1 to only use reliable records (record.reliable!0), 0 to use all
    'testdb',[],...
    'mousedb',[],...
    'groupdb',[],...
    'measuredb',[],...
    'extra_options','',...
    };

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
    if rem(nvarargin,2)==1
        logmsg('Odd number of varguments');
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

if isempty(mousedb) %#ok<NODEF>
    mousedb=load_mousedb;
end
if isempty(groupdb) %#ok<NODEF>
    groupdb=load_groupdb;
end
if isempty(measuredb) %#ok<NODEF>
    measuredb=load_measuredb;
end
if ischar(extra_options) %#ok<NODEF>
    extra_options=split(extra_options,',');
end
for i=1:2:length(extra_options)
    assign(trim(extra_options{i}),extra_options{i+1});
end

if ischar(measure)
    measuress=get_measures(measure,measuredb);
else
    measuress=measure;
end
if isempty(measuress)
    errormsg(['Could not find measure ' measure ]);
    return
end
measurelabel=measuress.label;

if ischar(groups)
    groupss=get_groups(groups,groupdb);
else
    groupss=groups;
end
n_groups=length(groups);

% complete filters
for g=1:n_groups
    groupss(g).filter=group2filter(groupss(g),groupdb);
end % g

linehead = '';
switch measuress.datatype
    case {'oi','ec','lfp','tp','ls','fret','fp'}
        reload = false;
        if isempty(expdb_cache) || ...
                ~isfield(expdb_cache,measuress.datatype) || ...
                ~isfield( expdb_cache.(measuress.datatype),'type') || ...
                ~strcmp(expdatabases(measuress.datatype), expdb_cache.(measuress.datatype).type)
            reload = true;
        else
            d = dir(expdb_cache.(measuress.datatype).filename);
            if isempty(d) % probably concatenated database
                reload = false;
            elseif ~strcmp(d.date, expdb_cache.(measuress.datatype).date) % i.e. changed
                reload = true;
            end
        end
        
        if exist('dbname','var') && ischar(dbname) %#ok<NODEF> % alternative db specified
            if ~exist(dbname,'file')
                if exist(fullfile(expdatabasepath,dbname),'file')
                    dbname = fullfile(expdatabasepath,dbname);
                end
            end
            if ~exist(dbname,'file')
                errormsg(['Database ' dbname ' does not exist.']);
                expdb_cache.(measuress.datatype).db = [];
                expdb_cache.(measuress.datatype).filename  = dbname;
                return
            end
            if ~reload && ~strcmp(expdb_cache.(measuress.datatype).filename,dbname)
                reload = true;
            end
        end
        
        if reload
            expdb_cache.(measuress.datatype).type = expdatabases(measuress.datatype) ;
            if exist('dbname','var') && ischar(dbname)
                temp = load(dbname);
                expdb_cache.(measuress.datatype).db = temp.db;
                expdb_cache.(measuress.datatype).filename  = dbname;
                clear('temp');
            else
                [expdb_cache.(measuress.datatype).db,expdb_cache.(measuress.datatype).filename] = ...
                    load_testdb(expdb_cache.(measuress.datatype).type);
            end
            d = dir(expdb_cache.(measuress.datatype).filename);
            expdb_cache.(measuress.datatype).date = d.date;
        else
            logmsg(['Using cache of ' expdb_cache.(measuress.datatype).filename '. Type ''clear functions'' to clear cache.']);
        end
        
        testdb = expdb_cache.(measuress.datatype).db;
    otherwise
        testdb=[];
end

% exclude groups for which we have too few points
if exist('min_n','var')
    min_n=str2double(min_n); %#ok<NODEF>
else
    min_n=1;
end

results = cell(1,n_groups);
dresults = cell(1,n_groups);

for g=1:n_groups
    newlinehead=[linehead groupss(g).name ': '];
    [results{g},dresults{g}]=get_measurements_for_group( groupss(g),measuress,value_per,mousedb,testdb,extra_options,newlinehead);
    n=sum(~isnan(results{g})) ;
    if n<min_n
        results{g}=nan;
        logmsg(['Fewer than ' num2str(min_n) ' datapoints.']);
    end
    switch value_per
        case 'group'
            results{g}=nanmean(results{g},ndims(results{g}));
            dresults{g}=norm(dresults{g}(~isnan(dresults{g})));
            if numel(results{g})==length(results{g})
                logmsg([newlinehead num2str(results{g},3)]);
            else
                logmsg([newlinehead ' array']);
            end
            
        otherwise
            logmsg([ 'measure = ' measuress.measure ', group=' groupss(g).name ...
                ' : mean = ' num2str(nanmean(double(results{g}(:)))) ...
                ' , std = ' num2str(nanstd(double(results{g}(:)))) ...
                ' , sem = ' num2str(sem(double(results{g}(:)))) ...
                ' , N = ' num2str(min(n(:)))]);
    end
end % g (groups)

return


function [results, dresults]=get_measurements_for_group( group, measure, value_per, mousedb,testdb,extra_options,linehead)
results=[];
dresults=[];

if strcmp(trim(group.name),'empty')
    return
end
indmice=find_record(mousedb,group.filter);

logmsg(['Group ' group.name ' contains ' num2str(length(indmice)) ' mice.']);

if isempty(indmice)
    return
end

for i_mouse=indmice
    mouse=mousedb(i_mouse);
    newlinehead = linehead;
    [res,dres]=get_measurements_for_mouse( mouse, measure, group.criteria, value_per,testdb,extra_options,newlinehead);
    
    switch value_per
        case 'mouse' %{'mouse','group'}
            newlinehead = [newlinehead 'mouse=' mouse.mouse ',']; %#ok<AGROW>
            res=nanmean(res,ndims(res));
            dres=norm(dres(~isnan(dres)));
            
            if numel(res)==length(res)
                logmsg([newlinehead measure.name '=' num2str(res,3)]);
            else
                logmsg([newlinehead measure.name '= array']);
            end
        case 'group'
            logmsg('Changed behavior from group on 2013-04-27');
    end
    
    
    if ~isempty(res) && numel(res)==length(res)
        results=[results(:)' res(:)'];
        dresults=[dresults(:)' dres(:)'];
    elseif isempty(res)
        % do nothing
    elseif isempty(results)
        results = res;
        dresults = dres;
    else
        % ugly and not very general!
        xl = min(size(results,1),size(res,1));
        yl = min(size(results,2),size(res,2));
        zl = size(res,3);
        results(1:xl,1:yl,end+1:(end+zl)) = res(1:xl,1:yl,1:zl);
        dresults(1:xl,1:yl,end+1:(end+zl)) = dres(1:xl,1:yl,1:zl);
    end
end % i_mouse (mice)
return


function [results, dresults]=get_measurements_for_mouse( mouse, measure, criteria,value_per, testdb,extra_options,linehead)
results=[];
dresults=[];

if isempty(testdb)
    return
end

isolation='';
for i=1:2:length(extra_options)
    assign(trim(extra_options{i}),extra_options{i+1});
end

if strcmpi(measure.datatype,'genenetwork')
    results=get_genenetwork_probe(mouse.strain,measure.stim_type,measure.measure);
end

if isempty(measure.stim_type) || strcmp(measure.stim_type,'*')
    switch measure.measure
        case 'sex', % only once per mouse
            results=strcmp(mouse.sex,'male');
            return
        case 'weight'
            results = get_mouse_weight( mouse );
            return
        case 'bregma2lambda'
            if ~isempty(mouse.bregma2lambda)
                results = mouse.bregma2lambda(1);
            else
                results = [];
            end
            return
        case 'skullwidth'
            if ~isempty(mouse.bregma2lambda)
                results = mouse.bregma2lambda(2);
            else
                results = [];
            end
            return
    end
end


cond=[ 'mouse=' mouse.mouse  ];
cond=[cond ', datatype=' measure.datatype  ];
if ~isempty(measure.stim_type)
    cond=[cond ', stim_type=' measure.stim_type  ];
end
if isfield(testdb,'stim_type') && exist('stim_type','var')
    cond=[cond ', (stim_type=' stim_type ')' ];
end


if isfield(testdb,'experimenter') && exist('experimenter','var')
    cond=[cond ', (experimenter=' experimenter ')' ];
end
if isfield(testdb,'stim_onset') && exist('stim_onset','var')
    cond=[cond ', (stim_onset=' stim_onset ')' ];
end
if isfield(testdb,'comment') &&  exist('comment','var')
    comment=trim(comment); %#ok<NODEF>
    if comment(1)=='{'
        comment = split( comment(2:end-1));
    else
        comment = {comment};
    end
    for i=1:length(comment)
        cond=[cond ', comment=*' comment{i} '*']; %#ok<AGROW>
    end
end
if isfield(testdb,'comment') &&  exist('nocomment','var')
    nocomment=trim(nocomment); %#ok<NODEF>
    if nocomment(1)=='{'
        nocomment = split( nocomment(2:end-1));
    else
        nocomment = {nocomment};
    end
    for i=1:length(nocomment)
        cond=[cond ', comment!*' nocomment{i} '*']; %#ok<AGROW>
    end
end
if exist('test','var')
    cond=[cond ', test=*' test '*'];
end
if ~isempty(isolation)
    switch isolation
        case 'ok'
            cond=[cond ', (comment=*perfect*|comment=*good*|comment=*nice*|comment=*ok*)'];
        case 'good'
            cond=[cond ', (comment=*perfect*|comment=*good*)'];
        case 'nice'
            cond=[cond ', (comment=*perfect*|comment=*nice*|comment=*good*)'];
        case 'perfect'
            cond=[cond ', (comment=*perfect*)'];
    end
end
if exist('eyes','var') % eye is already used for matlab function
    cond=[cond ', eye=*' eyes '*'];
end
if exist('hemisphere','var')
    if strcmp(hemisphere,'notleft')
        % to make both right, ugly 2013-12-12
        cond=[cond ', hemisphere!*left*'];
    else
        cond=[cond ', hemisphere=*' hemisphere '*'];
    end
end

indtests=find_record(testdb,cond);
for i_test=indtests
    testrecord=testdb(i_test);
    newlinehead = [linehead recordfilter(testrecord) ':'];
    [res,dres]=get_measurements_for_test( testrecord,mouse, measure,criteria,value_per,extra_options,newlinehead);
    switch value_per
        case {'test','stack'}
            if ~isempty(res)
                res=nanmean(res);
                dres=norm(dres(~isnan(dres)));
                logmsg([newlinehead measure.name '='  num2str(res,3)]);
            end
        case {'testsum','stacksum'} % take the sum over cells/ROIs in test or stack-record
            if ~isempty(res)
                dres=norm(dres(~isnan(dres))) .* sum(~isnan(res));
                res=nansum(res);
                logmsg([newlinehead measure.name '='  num2str(res,3)]);
            end
            
            
    end
    
    if ~isempty(res) && numel(res)==length(res) % i.e. 1D results
        results=[results(:)' res(:)'];
        dresults=[dresults(:)' dres(:)'];
    elseif isempty(res)
        % do nothing
    elseif isempty(results)
        results = res;
        dresults = dres;
    else
        % ugly and not very general!
        sr = size(results);
        try
            if any(sr(1:end-1)~=size(res))
                logmsg('Result arrays are not all the same size');
            end
        catch
            logmsg('Result arrays are not all the same size');
        end
        xl = min(size(results,1),size(res,1));
        yl = min(size(results,2),size(res,2));
        
        results(1:xl,1:yl,end+1) = res(1:xl,1:yl); %#ok<AGROW>
        dresults(1:xl,1:yl,end+1) = dres(1:xl,1:yl); %#ok<AGROW>
    end
    if any(size(results)~=size(dresults))
        logmsg('Sizes of RESULTS and DRESULTS are not equal');
    end
end % test records


function [results, dresults]=get_measurements_for_test(testrecord, mouse, measure, criteria,value_per,extra_options,linehead)
results = [];
dresults = [];

for i=1:2:length(extra_options)
    assign(trim(extra_options{i}),extra_options{i+1});
end

if exist('reliable','var') && eval(reliable)==1 && length(testrecord.reliable)==1
    if isnumeric(testrecord.reliable)
        if testrecord.reliable==0
            return % no need to check individual cells
        end
    elseif eval(testrecord.reliable)==0
        return % no need to check individual cells
    end
end

if ~exist('reliable','var') && length(testrecord.reliable)==1 && testrecord.reliable==0
    if isnumeric(testrecord.reliable)
        if testrecord.reliable==0
            return % no need to check individual cells
        end
    elseif eval(testrecord.reliable)==0
        return % no need to check individual cells
    end
end



if exist('min_blocks','var')
    if ischar(min_blocks) %#ok<NODEF>
        min_blocks=eval(min_blocks);
    end
    if size(testrecord.response_all,1)<min_blocks
        logmsg(['Fewer than ' num2str(min_blocks) ' blocks.']);
        results=nan;
        return
    end
end

switch measure.datatype
    case 'ec'
        if ~isfield(testrecord,'datatype') || ~strcmp(measure.datatype,'ec')
            results = NaN;
            return
        end
    case 'lfp'
        if ~isfield(testrecord,'datatype') || ~strcmp(measure.datatype,'lfp')
            results = NaN;
            return
        end
        
end

switch measure.measure
    case 'weight'
        results = get_mouse_weight( mouse);
    case 'age'
        results = age(mouse.birthdate,testrecord.date);
        dresults = NaN;
    case 'expdate'  % day number since 1-1-0000
        results=datenum(testrecord.date,'yyyy-mm-dd') ;
    otherwise
        if strcmp(measure.measure(1:min(end,4)),'file')
            switch measure.datatype
                case 'tp'
                    saved_data_file = fullfile(tpdatapath(testrecord),[measure.datatype '_measures.mat']);
                case {'ec','lfp'}
                    saved_data_file = fullfile(ecdatapath(testrecord),testrecord.test,[measure.datatype '_measures.mat']);
            end
            if exist(saved_data_file,'file')
                saved_data = load(saved_data_file); 
                results = [];
                try
                    for c = 1:length(saved_data.measures) % channel or cell
                        eval(['results = [results saved_data.measures(' num2str(c) ').' measure.measure(6:end) '];']);
                    end
                catch me
                    logmsg(['Error in retrieving ' measure.measure(6:end) ' from ' saved_data_file '. ' me.identifier ]);
                end
                logmsg(['Retrieved ' ...
                    measure.measure(6:end) ' from ' saved_data_file ...
                    '. Results is of size ' num2str(size(results)) ]);
                dresults = nan(size(results));
            end
        else
            [results,dresults] = get_compound_measure_from_record(testrecord,measure.measure,criteria,extra_options);
            results = double(results);
            dresults = double(dresults);
            if strcmpi(value_per,'neurite')
                linked2neurite = get_compound_measure_from_record(testrecord,'linked2neurite',criteria,extra_options);
                if length(linked2neurite)~=length(results)
                    errormsg('Not an equal number of values and neurite numbers.');
                    return
                end
                uniqneurites =  uniq(sort(linked2neurite(~isnan(linked2neurite))));
                res = [];
                dres = [];
                for neurite = uniqneurites(:)'
                    res = [res nanmean(results(linked2neurite==neurite))]; %#ok<AGROW>
                    dres = [dres nanstd(results(linked2neurite==neurite))]; %#ok<AGROW>
                end
                results = res;
                dresults = dres;
            end
            if isempty(results) && ~strcmp(measure.measure,'depth')
                [results,dresults]=get_valrecord(testrecord,measure.measure,mouse);
            end
        end
        if ~isempty(results)
            switch value_per
                case {'measurement','neurite'}
                    if ndims(results)<3 && numel(results)<200 %#ok<ISMAT>
                        textres=mat2str(results',3);
                        if ~isempty(textres) && textres(1)=='['
                            textres=textres(2:end-1);
                        end
                    else
                        textres = [num2str(ndims(results)) 'd array'];
                    end
                    logmsg([linehead measure.name '=' textres]);
            end
        end
end
return



