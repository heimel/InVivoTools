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
max_snr='inf';
min_snr='0';
for i=1:2:length(extra_options)
    assign(extra_options{i},extra_options{i+1});
end
min_snr=eval(min_snr);
max_snr=eval(max_snr);
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
        disp(['GET_MEASURE_FROM_RECORD: Something wrong with ' limit ]);
        return
    end
end

acc_open = find(measure=='{'); % i.e. trigger prescription
if ~isempty(acc_open)
    acc_close = find(measure(acc_open:end)=='}');
    if isempty(acc_close)
        errordlg(['No closing accolade after opening in measure ' measure ]);
        disp(['GET_MEASURE_FROM_RECORD: No closing accolade after opening in measure ' measure ]);
        return
    end
    trigger = str2double(measure(acc_open+1:acc_open+acc_close-2));
    measure = measure(1:acc_open-1);
else 
    trigger = 1;
end


if isfield(record,'measures')
    for c=1:length(record.measures) % over all cells
        measures = record.measures(c);
        
        
        if verbose && isfield(measures,measure)
            disp([ recordfilter(record) ': ' measure ' present']);
        end
            
        if strcmp(record.datatype,'ec')==1
            get=0;
            if isfield(measures,'usable') && measures.('usable')==1
                switch celltype
                    case 'all'
                        get=1;
                    case 'mu'
                        if strcmp(measures.('type'),'mu')==1
                            get=1;
                        end
                    case 'su'
                        if strcmp(measures.('type'),'su')==1
                            get=1;
                        end
                end
            end
            if isfield(measures,'snr') && measures.snr<min_snr % nicer to make a extra_options snr
                disp('GET_MEASURE_FROM_RECORD: Use of min_snr is deprecated. Use limit instead');
                get=0;
            end
            if isfield(measures,'snr') && measures.snr>max_snr
                disp('GET_MEASURE_FROM_RECORD: Use of max_snr is deprecated. Use limit instead');
                get=0;
            end
        else % for instance 'lfp'
            get=1;
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
                    get = 0;
                end
            catch me
                switch me.identifier
                    case 'MATLAB:nonExistentField'
                        get = 0;
                    case 'MATLAB:undefinedVariable'
                        errormsg(['Problem with criteria: ' criteria '. Perhaps forgotten to append ''measures.''?']);
                        rethrow(me);
                    case 'MATLAB:UndefinedFunction'
                        errormsg(['Problem with criteria: ' criteria '. Perhaps forgotten accolades or forgotten to append ''measures.''?']);
                        rethrow(me);
                    otherwise
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
                        get = 0;
                    end
                elseif isfield(measures,'index')
                    if length(record.reliable)<measures.index+1
                        str=['Reliable vector too short for ' recordfilter(record) '. Note that the first entry is the multi-unit.' ];
                        disp(['GET_MEASURE_FROM_RECORD: ' str]);
                        errordlg(str,'Get measure from record');
                    else
                        if ~record.reliable(measures.index+1)
                            get = 0;
                        end
                    end
                end
            end
        end
        if exist('anesthetic','var')
            if isempty(findstr(anesthetic,record.anesthetic))
                get = 0;
            end
        end
        
        
        if exist('depth','var') && ~isempty(depth) && depth~=0
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
        if exist('rate_max_limit','var') && ~isempty(rate_max_limit)
            disp('GET_MEASURE_FROM_RECORD: Use of rate_max_limit is deprecated. Use limit instead');
            if isfield(measures,'rate_max')
                if iscell(measures.rate_max)
                    if measures.rate_max{1}<rate_max_limit(1) || ...
                            measures.rate_max{1}>rate_max_limit(2)
                        get = 0;
                    end
                else
                    if measures.rate_max<rate_max_limit(1) || ...
                            measures.rate_max>rate_max_limit(2)
                        get = 0;
                    end
                end
            end
        end
        
        if exist('limit','var') && ~isempty(limit)
            if mod(length(limit),2)==1
                msg= 'Odd number of arguments to limit. Use like limit,{''rate_max{1}'';[1 inf];''depth'';[300 400]';
                errordlg(msg,'Get measure from record');
                disp(['GET_MEASURE_FROM_RECORD: ' msg]);
                return
            end
            n_limits = length(limit)/2;
            for l = 1:n_limits
                try
                    if limit{l*2-1}(1)=='''' && limit{l*2-1}(end)==''''
                        limit{l*2-1}=limit{l*2-1}(2:end-1);
                    end
                    v = eval(['measures.' limit{l*2-1}]);
                    % using try instead of isfield, because of things like
                    %  rate_max{1} 
                catch
                    try
                        v = eval(['record.' limit{l*2-1}]);
                    catch
                        get = 0;
                        continue
                    end
                end
                if ~isempty(v)
                    if islogical(v)
                        v = double(v);
                    end
                    if isnumeric(v)
                        ranges = eval(limit{l*2});
                    else
                        ranges = limit{l*2};
                    end                        
                    if ~iscell(ranges)
                        ranges = {ranges};
                    end
                    take = false;
                    for i = 1:length(ranges)
                        if ~iscell(v)
                            v = {v};
                        end
                        for j=1:length(v)
                            
                            if isnumeric(v{j})
                                if numel(v{j})>1
                                   errormsg([limit{l*2-1} ' has multiple values in ' recordfilter(record)]);
                                   return
                                end
                                if length(ranges{i})==2
                                    if v{j}>=ranges{i}(1) &&  v{j}<=ranges{i}(2)
                                        take = true;
                                    end
                                elseif length(ranges{i})==1
                                    if v{j}==ranges{i}
                                        take = true;
                                    end
                                end
                            elseif ischar(v{j})
                                if strcmp(v{j},ranges{i})
                                    take = true;
                                end
                            end
                        end
                    end
                    
                    if ~take
                        get = 0;
                        continue
                    end
                   
                end
            end
        end
        
        
        if exist('variable','var')
            if ~isfield(measures,'variable') || ...
                    strcmp(measures.variable,variable)==0
                get = 0;
            end
        end
        tempval = NaN;
        tempval_sem = [];
        if get
            if isfield(measures,measure)
                if ~isempty(measures.(measure))
                    tempval = measures.(measure);
                else
                    flds = fields(record);
                    disp(['GET_MEASURE_FROM_RECORD: ' ...
                        flds{1} '=' record.(flds{1}) ', ' ...
                        flds{2} '=' record.(flds{2}) ', ' ...
                        flds{3} '=' record.(flds{3}) ', ' ...
                        flds{4} '=' record.(flds{4}) ', ' ...
                        ', measure = ' measure ' is empty.']);
                end
                switch measure  % ugly here, should be more general
                    case 'halfmax_deg'
                        if measures.halfmax_deg>80
                            disp([record. mouse ' ' record.test ' has a very large rf halfmax. Discarding']);
                            tempval = nan ;
                        end
                end
                if iscell(tempval)
                    if trigger>length(tempval)
                        tempval = nan;
                    else
                        tempval = squeeze(tempval{trigger});
                    end
                end
            else % no field with measure name
                switch measure
                    case 'linked2neurite'
                        tempval = record.ROIs.celllist(c).neurite(1);
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
                            disp('GET_MEASURE_FROM_RECORD: Range should be measure already. Reanalyze test records.');
                            curve = measures.('curve');
                            if iscell(curve) % then only use first
                                curve = curve{1};
                            end
                            tempval = curve(1,:) ;
                        end
                    case 'response' % subtract spontaneous rate
                        if isfield(measures,'curve')
                            disp('GET_MEASURE_FROM_RECORD: Response should be measure already. Reanalyze test records.');
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
                        disp('GET_MEASURE_FROM_RECORD: Use of stim as measure is deprecated. Use range instead');
                        curve = measures.('curve');
                        tempval = curve(1,:);
                    case 'time_peak_highcontrast'
                        disp('GET_MEASURE_FROM_RECORD: TIME_PEAK_HIGHCONTRAST IS DEPRECATED AND RETURNS PREFERRED STIMULUS');
                        curve = measures.('curve');
                        time_peak = measures.time_peak; 
                        if iscell(time_peak);
                            time_peak = time_peak{1};
                        end
                        tempval = time_peak;
                    case 'variance'
                        curve = measures.('curve');
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
            
        end % if get
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
    disp('GET_MEASURE_FROM_RECORD: sizes of VAL and VAL_SEM are not equal');
end
