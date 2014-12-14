function [val,val_sem]=get_measure_from_record(record,measure,criteria,extra_options)
%GET_MEASURE_FROM_RECORD gets measure from measures field in testdatabase
%
% 2007-2014, Alexander Heimel

if nargin<4
    extra_options = {};
end

celltype = 'all'; % can be overwritten by extra_options
reliable = 1; % by default don't use records with reliable field set to 0.

val = [];
val_sem = [];

layer='';
%max_snr='inf';
%min_snr='0';
for i=1:2:length(extra_options)
    assign(trim(extra_options{i}),extra_options{i+1});
end
if exist('range_limit','var')
    range_limit = eval(range_limit); %#ok<NODEF>
else
    range_limit = [];
end
if exist('rate_max_limit','var')
    rate_max_limit = eval(rate_max_limit); %#ok<NODEF>
else
    rate_max_limit = [];
end
if exist('verbose','var')
    verbose = eval(verbose); %#ok<NODEF>
else
    verbose = 0;
end

if exist('limit','var')
    try
        limit = trim(limit); %#ok<NODEF>
        if limit(1)=='{' && limit(end)=='}'
            limit = limit(2:end-1);
        end
        limit(limit==';')=',';
        limit = split(limit,',',true);
    catch
        errormsg(['Something wrong with ' limit ]);
        return
    end
    
    if mod(length(limit),2)==1
        errormsg('Odd number of arguments to limit. Use like limit,{''rate_max{1}'';[1 inf];''depth'';[300 400]');
        return
    end
    n_limits = length(limit)/2;
    limitranges_num = cell(1,n_limits);
    limitranges_str = cell(1,n_limits);
    for l = 1:n_limits  % remove 's
        if limit{l*2-1}(1)=='''' && limit{l*2-1}(end)==''''
            limit{l*2-1}=limit{l*2-1}(2:end-1);
        end
        try
            limitranges_num{l} =  eval(limit{l*2});
        catch me
            limitranges_num{l} = [];
        end
        limitranges_str{l} = limit{l*2};
        if ~iscell(limitranges_num{l})
            limitranges_num{l} = {limitranges_num{l}};
        end
        if ~iscell(limitranges_str{l})
            limitranges_str{l} = {limitranges_str{l}};
        end
    end
else
    limit = '';
    n_limits = 0;
end

acc_open = find(measure=='{'); % i.e. trigger prescription
if ~isempty(acc_open)
    acc_close = find(measure(acc_open:end)=='}');
    if isempty(acc_close)
        errormsg(['No closing accolade after opening in measure ' measure ],true);
    end
    trigger = str2double(measure(acc_open+1:acc_open+acc_close-2));
    measure = measure(1:acc_open-1);
else
    trigger = 1;
end


get = 1;
if exist('anesthetic','var')
    if isempty(strfind(lower(record.anesthetic),lower(anesthetic)))
        get = 0;
    end
end
if exist('depth','var') && ~isempty(depth) && depth~=0 %#ok<NODEF>
    if record.depth ~= str2double(depth)
        get = 0;
    end
end
if ~isempty(layer)
    if isfield(record,'depth')
        depth=record.depth-record.surface;
        switch layer
            case 'supergranular'
                if depth>450
                    get=0;
                end
            case 'subgranular'
                if depth<550
                    get=0;
                end
            case {'4','granular'}
                if depth>550 || depth<350
                    get=0;
                end
            case 'all'
        end
    end
end
if ~get
    return
end


if isfield(record,'measures')
    if verbose && isfield(record.measures,measure)
        logmsg([ recordfilter(record) ': ' measure ' present']);
    end
    if strcmp(record.datatype,'ec')==1
        ephysunits = true;
    else
        ephysunits = false;
    end
    if exist('rate_max_limit','var') && ~isempty(rate_max_limit)
        errormsg('rate_max_limit is deprecated and is ignored. Use limit instead.',true);
    end
    if exist('min_snr','var')
        errormsg('min_snr is deprecated and is ignored. Use limit instead.',true);
    end
    if exist('max_snr','var')
        errormsg('min_snr is deprecated and is ignored. Use limit instead.',true);
    end
    
    
    for c=1:length(record.measures) % over all cells
        get = 1;
        measures = record.measures(c);
        if ephysunits
            if isfield(measures,'usable') && measures.('usable')==1
                switch celltype
                    case 'mu'
                        if ~strcmp(measures.('type'),'mu')
                            continue % next c
                        end
                    case 'su'
                        if ~strcmp(measures.('type'),'su')
                            continue % next c
                        end
                end
            end
            
        end
        
        if ~isempty(criteria)
            try % criteria
                evaluated_criteria = eval(criteria);
                if length(evaluated_criteria)>1
                    logmsg('Criteria do not evaluate to a single boolean.');
                else
                    % included
                end
                if ~all(evaluated_criteria)
                    continue % next c
                end
            catch me
                switch me.identifier
                    case 'MATLAB:nonExistentField'
                        continue % next c
                    case 'MATLAB:undefinedVariable'
                        errormsg(['Problem with criteria: ' criteria '. Perhaps forgotten to append ''measures.''?']);
                        rethrow(me);
                    case 'MATLAB:UndefinedFunction'
                        errormsg(['Problem with criteria: ' criteria '. Perhaps forgotten accolades or forgotten to append ''measures.''?']);
                        rethrow(me);
                    otherwise
                        logmsg(['Problem with criteria: ' criteria ' for ' recordfilter(record)]);
                        logmsg(me.message);
                        logmsg(me.identifier);
                end
            end
        end
        
        % only take reliable
        if reliable==1 && ~isempty(record.reliable)
            if ischar(record.reliable)
                warning('GET_MEASURE_FROM_RECORD:RELIABLE_TEXT','GET_MEASURE_FROM_RECORD: Reliable is text. Ignoring');
                warning('off','GET_MEASURE_FROM_RECORD:RELIABLE_TEXT');
            else
                if length(record.reliable)==1
                    if record.reliable == 0
                        continue % next c
                    end
                elseif isfield(measures,'index')
                    if length(record.reliable)<measures.index+1
                        errormsg(['Reliable vector too short for ' recordfilter(record) '. Note that the first entry is the multi-unit.' ]);
                    else
                        if ~record.reliable(measures.index+1)
                            continue % next c
                        end
                    end
                end
            end
        end
        for l = 1:n_limits
            try
                v = measures.(limit{l*2-1}); % goes wrong if limit has {}
            catch
                try
                    v = eval(['measures.' limit{l*2-1}]);
                    % using eval instead of isfield, because of things like
                    %  rate_max{1}
                catch
                    try
                        v = eval(['record.' limit{l*2-1}]);
                    catch
                        get = 0;
                        break
                    end
                end
            end
            if ~isempty(v)
                if islogical(v)
                    v = double(v);
                end
                if isnumeric(v)
                    ranges = limitranges_num{l};
                else
                    ranges = limitranges_str{l};
                end
                if ~iscell(v)
                    v = {v};
                end
                take = false;
                for i = 1:length(ranges) % when do you get multiple ranges? this code looks incorrect for multiple ranges
                    for j=1:length(v)
                        if isnumeric(v{j})
                            if numel(v{j})>1
                                errormsg([limit{l*2-1} ' has multiple values in ' recordfilter(record)]);
                                return
                            end
                            if length(ranges{i})==2
                                if v{j}>=ranges{i}(1) &&  v{j}<=ranges{i}(2)
                                    take = true;
                                    break % from j, but not from i?
                                end
                            elseif length(ranges{i})==1
                                if v{j}==ranges{i}
                                    take = true;
                                    break % from j, but not from i?
                                end
                            end
                        elseif ischar(v{j})
                            if strcmp(v{j},ranges{i})
                                take = true;
                                break
                            end
                        end
                    end % j
                end % i
                
                if ~take
                    get = 0;
                    break
                end
                
            end
        end % limit l
        if ~get
            continue % next c
        end
        
        if exist('variable','var')
            if ~isfield(measures,'variable') || ...
                    strcmp(measures.variable,variable)==0
                continue % next c
            end
        end
        
        tempval = NaN;
        tempval_sem = [];
        
        if isfield(measures,measure)
            if ~isempty(measures.(measure))
                tempval = measures.(measure);
            else
                logmsg([recordfilter(record) ', measure = ' measure ' is empty.']);
                tempval = NaN;
            end
            if iscell(tempval)
                if trigger>length(tempval)
                    tempval = NaN;
                else
                    tempval = squeeze(tempval{trigger});
                end
            end
        else % no field with measure name
            switch measure
                case 'linked2neurite'
                    if length(record.ROIs.celllist)<c
                        logmsg(['ROIs in record is shorter than measures for ' recordfilter(record)]);
                        tempval = NaN;
                    else
                        tempval = record.ROIs.celllist(c).neurite(1);
                    end
                case 'psth.tbins' %deprecated, analysis should put measure in measures and use routines above
                    if isfield(measures,'psth') && isfield(measures.psth,'tbins')
                        tempval = measures.psth.tbins;
                    end
                case 'psth.data' %deprecated, analysis should put measure in measures and use routines above
                    if isfield(measures,'psth') && isfield(measures.psth,'data')
                        tempval = measures.psth.data;
                    end
                case 'depth'
                    tempval = record.depth-record.surface;
                case {'range','parameter'} % parameter is deprecated
                    if isfield(measures,'curve')
                        logmsg('Range should be measure already. Reanalyze test records.');
                        curve = measures.('curve');
                        if iscell(curve) % then only use first
                            curve = curve{1};
                        end
                        tempval = curve(1,:) ;
                    end
                case 'response' % subtract spontaneous rate
                    if isfield(measures,'curve')
                        logmsg('Response should be measure already. Reanalyze test records.');
                        curve = measures.('curve');
                        if iscell(curve) % multiple triggers
                            curve = curve{1}; % then only use first
                        end
                        if isfield(measures,'rate_spont')==1
                            % subtract spontaneous
                            rate_spont = measures.('rate_spont');
                            curve(2,:)=curve(2,:)-rate_spont(1);
                        end
                        tempval=curve(2,:);
                        tempval_sem=curve(4,:);
                    end
                case 'rate' % no subtraction of spontaneous rate
                    if isfield(measures,'curve')
                        curve = measures.('curve');
                        if iscell(curve)
                            curve = curve{trigger};
                            tempval = curve(2,:);
                            tempval_sem = curve(4,:);
                        end
                    end
                case 'rate_normalized_by_stim1' % no subtraction of spontaneous rate
                    if isfield(measures,'curve')
                        curve=measures.('curve');
                        if curve(2,1)==0
                            curve(2,1)=NaN;
                        end
                        tempval = curve(2,:)/curve(2,1);
                        tempval_sem = curve(4,:)/curve(4,1);
                    end
                case 'stim'
                    logmsg('Use of stim as measure is deprecated. Use range instead');
                    curve = measures.('curve');
                    tempval = curve(1,:);
                case 'time_peak_highcontrast'
                    logmsg('TIME_PEAK_HIGHCONTRAST IS DEPRECATED AND RETURNS PREFERRED STIMULUS');
                    time_peak = measures.time_peak;
                    if iscell(time_peak);
                        time_peak = time_peak{1};
                    end
                    tempval = time_peak;
                case 'variance'
                    curve = measures.('curve');
                    if iscell(curve) % multiple triggers
                        curve = curve{1}; % then only use first
                    end
                    [~,ind] = max(curve(2,:)); % for highest response
                    tempval = curve(3,ind)^2;
            end
        end % no field with name
        
        if ~isempty(range_limit)
            if isfield(measures,'range')
                if ~iscell(measures.range)
                    measures.range = {measures.range};
                end
                ind = find(measures.range{1}>=range_limit(1) & measures.range{1}<=range_limit(end));
                if numel(tempval) == numel(measures.range{1})
                    tempval = nanmean( tempval(ind));
                elseif isempty(ind) % if none fit the range, do not produce an output
                    tempval = nan;
                end
            end
        end
        
        % next lines used to be out of if get
        if isempty(tempval_sem)
            tempval_sem = NaN(size(tempval));
        end
        val = [val tempval(:)']; %#ok<AGROW>
        val_sem = [val_sem tempval_sem(:)'  ]; %#ok<AGROW> % no sems
    end % next cell c
    
else % no field measures
    if isfield(record,measure)
        val = record.(measure);
        if islogical(val)
            val = double(val);
        end
        val_sem = NaN(size(val));
    end
end

if any(size(val)~=size(val_sem))
    logmsg('Sizes of VAL and VAL_SEM are not equal');
end
