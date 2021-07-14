function [results,dresults,measurelabels,wordtypes]=get_compound_measurements(groups,measures,varargin)
%GET_COMPOUND_MEASUREMENTS
%
%    [results,dresults,measurelabels,wordtypes] = get_compound_measurements(groups,measures,varargin)
%
% 2007-2017, Alexander Heimel
%

pos_args={...
    'value_per','measurement',... % 'group','mouse','test','stack','measurement' 
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
        warning([upper(mfilename) ':ODDNUMBER_OF_ARGUMENTS'],...
            [upper(mfilename) ': Odd number of varguments']);
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
    extra_options = ivt_split(extra_options,',');
end

if ischar(measures)
    measures = strtrim(measures);
end

% measures still contains multiple measures
if ischar(measures) && ~isempty(find(measures==',',1))
    measures = ivt_split(measures,',',true);
    results = cell(1,length(measures));
    dresults = cell(1,length(measures));
    measurelabels = cell(1,length(measures));
    for m=1:length(measures)
        [result,dresult,measurelabel] = get_compound_measurements(groups,measures{m},...
            'testdb',testdb,...
            'mousedb',mousedb,...
            'groupdb',groupdb,...
            'measuredb',measuredb,... 
            'value_per',value_per,...
            'extra_options',extra_options ...
            );
        if ~isempty(result)
            results{m}=result{1};
            dresults{m}=dresult{1};
            measurelabels{m}=measurelabel{1};
        else
            results{m} = [];
            dresults{m} = [];
            measurelabels{m} = '';
        end
    end
    return
end

logmsg(measures);

measuresstring=measures;
results={};
dresults={};
measurelabels={};
words={};
wordtypes={};
results_list={};
dresults_list={};
rawdata = {};
while ~isempty(measuresstring)
    [words{end+1},wordtypes{end+1},measuresstring]=get_next_word(measuresstring); %#ok<AGROW>
    switch wordtypes{end}
        case 'measure'
            [results_list{end+1},dresults_list{end+1},measurelabels{end+1}, rawdata]=get_measurements(groups,words{end},...
                'testdb',testdb,...
                'mousedb',mousedb,...
                'groupdb',groupdb,...
                'measuredb',measuredb,...  
                'value_per',value_per,...
                'extra_options',extra_options ...
                ); %#ok<AGROW>
        case 'compound'
            [results,dresults,measurelabel,wordtype] = get_compound_measurements(groups,words{end}(2:end-1),...
                'testdb',testdb,...
                'mousedb',mousedb,...
                'groupdb',groupdb,...
                'measuredb',measuredb,... %                'reliable',reliable,...
                'value_per',value_per,...
                'extra_options',extra_options ...
                );
            if length(wordtypes)>1 &&  strcmp(wordtypes{end-1},'measure') % interpret as logical indexing
                results_list{end}{1} = results_list{end}{1}(logical(results{1}{1}));
                dresults_list{end}{1} = dresults_list{end}{1}(logical(results{1}{1}));
            else
                results_list{end+1}=results{1}; %#ok<AGROW>
                dresults_list{end+1}=dresults{1}; %#ok<AGROW>
                measurelabels{end+1}=measurelabel{1};%#ok<AGROW>
                wordtypes{end}=wordtype{1};
            end
        case 'function'
            results_list{end+1}=[]; %#ok<AGROW>
            dresults_list{end+1}=[];%#ok<AGROW>
            measurelabels{end+1}=words{end};%#ok<AGROW>
        case 'scalar'
            results_list{end+1}=str2double(words{end}); %#ok<AGROW>
            dresults_list{end+1}=str2double(words{end}); %#ok<AGROW>
            measurelabels{end+1}=words{end}; %#ok<AGROW>
        case 'operator'
            results_list{end+1}=[]; %#ok<AGROW>
            dresults_list{end+1}=[]; %#ok<AGROW>
            measurelabels{end+1}=words{end}; %#ok<AGROW>
        otherwise
            errormsg(['Unknown word type ' wordtypes{end}],true);
    end
    
    
end

assignin('base', 'rawdata', rawdata);

if isempty(wordtypes)
    return
end

if strcmp(wordtypes{1},'operator')
    logmsg(['Measure ' measures ' starting with an operator.']);
    return
end
if strcmp(wordtypes{end},'operator')
    logmsg(['Measure ' measures ' ending with an operator.']);
    return
end
if strcmp(wordtypes{end},'function')
    logmsg(['Measure ' measures ' ending with a function.']);
    return
end


% evaluate functions (start from right)
w=length(measurelabels)-1;
while w>=1
    if strcmp(wordtypes{w},'function')
        [results_list,dresults_list,measurelabels,wordtypes]=...
            apply_function(measurelabels{w},results_list,dresults_list,measurelabels,wordtypes,w);
    end
    w=w-1;
end



% evaluate operators (start from left)
operators='^*/';
for operator=operators
    w=1;
    while w<=length(measurelabels)
        if strcmp(wordtypes{w},'operator')==1 && measurelabels{w}==operator
            [results_list,dresults_list,measurelabels,wordtypes]=...
                apply_operator(operator,results_list,dresults_list,measurelabels,wordtypes,w);
            w=w-1;
        else
            w=w+1;
        end
    end
end
operators='+-';
w=1;
while w<=length(measurelabels)
    if strcmp(wordtypes{w},'operator') && ...
            (measurelabels{w}==operators(1) ||measurelabels{w}==operators(2))
        [results_list,dresults_list,measurelabels,wordtypes]=...
            apply_operator(measurelabels{w},results_list,dresults_list,measurelabels,wordtypes,w);
        w=w-1;
    else
        w=w+1;
    end
end

operators='<>=!';
w=1;
while w<=length(measurelabels)
    if strcmp(wordtypes{w},'operator') && ...
            ~isempty(strfind(operators,measurelabels{w}))
        [results_list,dresults_list,measurelabels,wordtypes]=...
            apply_operator(measurelabels{w},results_list,dresults_list,measurelabels,wordtypes,w);
        w=w-1;
    else
        w=w+1;
    end
end

operators='|&';
w=1;
while w<=length(measurelabels)
    if strcmp(wordtypes{w},'operator') && ...
            ~isempty(strfind(operators,measurelabels{w}))
        [results_list,dresults_list,measurelabels,wordtypes]=...
            apply_operator(measurelabels{w},results_list,dresults_list,measurelabels,wordtypes,w);
        w=w-1;
    else
        w=w+1;
    end
end


results=results_list;
dresults=dresults_list;
return


function  [results_list,dresults_list,measurelabels,wordtypes]=...
    apply_function(func,results_list,dresults_list,measurelabels,wordtypes,w)

switch func
    case 'mean'
        func='nanmean';
    case 'std'
        func='nanstd';
    case 'not'
        func = 'nannot';
end

new_results={};
new_dresults={};
switch wordtypes{w+1}
    case 'measure'
        new_results = cell(1,length(results_list{w+1}));
        new_dresults = cell(1,length(results_list{w+1}));
        for r=1:length(results_list{w+1})
            new_results{r} = feval(func,results_list{w+1}{r});
            new_dresults{r} = nan*new_results{r};
        end
        new_measurelabel=[measurelabels{w} ' ' measurelabels{w+1}];
        new_wordtype='measure';
    case 'scalar'
        new_results = feval(func,results_list{w+1});
        if iscell(new_results)
            new_dresults = cell(size(new_results)); % corrected 2014-11-15
            for r=1:length(new_results)
                new_dresults{r} = nan*new_results{r};
            end
        else
            new_dresults = NaN;
        end
        new_measurelabel=[measurelabels{w} ' ' measurelabels{w+1}];
        new_wordtype='scalar';
end
wordtypes={ wordtypes{1:w-1},new_wordtype,wordtypes{w+2:end}};
measurelabels={measurelabels{1:w-1},new_measurelabel,measurelabels{w+2:end}};
results_list={ results_list{1:w-1} ,new_results,results_list{w+2:end}};
dresults_list={ dresults_list{1:w-1} ,new_dresults,dresults_list{w+2:end}};
return


function [results_list,dresults_list,measurelabels,wordtypes]=...
    apply_operator(operator,results_list,dresults_list,measurelabels,wordtypes,w)

switch operator
    case {'*','/','^'}
        operator=['.' operator];
    case '='
        operator = '==';
    case '!'
        operator = '~=';
    case '|'
        operator = '||';
    case '&'
        operator = '&&';
end

switch [wordtypes{w-1} ',' wordtypes{w+1}]
    case 'scalar,scalar'
        eval(['new_results=results_list{w-1}' operator 'results_list{w+1};']);
        warning('GET_COMPOUND_MEASUREMENTS:UNRELIABLE_DRESULTS',...
            'GET_COMPOUND_MEASUREMENTS: Operator evaluation not implemented for dresults');
        warning('off','GET_COMPOUND_MEASUREMENTS:UNRELIABLE_DRESULTS');
        new_dresults=nan*new_results; %#ok<NODEF>
        new_measurelabel=[measurelabels{w-1} ' ' measurelabels{w} ' ' measurelabels{w+1}];
        new_wordtype='scalar';
    case 'scalar,measure'
        new_results=cell(1,length(results_list{w+1}));
        new_dresults=cell(1,length(results_list{w+1}));
        for r=1:length(results_list{w+1})
            eval(['new_results{r}=results_list{w-1}' operator 'results_list{w+1}{r};']);
            new_dresults{r}=nan*new_results{r};
        end
        new_measurelabel=[measurelabels{w-1} ' ' measurelabels{w} ' ' measurelabels{w+1}];
        new_wordtype='measure';
    case 'measure,scalar'
        new_results={};
        for r=1:length(results_list{w-1})
            eval(['new_results{r}=results_list{w-1}{r}' operator 'results_list{w+1};']);
            eval(['new_dresults{r}=dresults_list{w-1}{r}' operator 'results_list{w+1};']);
            warning('GET_COMPOUND_MEASUREMENTS:UNRELIABLE_DRESULTS',...
                'GET_COMPOUND_MEASUREMENTS: Operator evaluation not implemented for dresults');
            warning('off','GET_COMPOUND_MEASUREMENTS:UNRELIABLE_DRESULTS');
        end
        new_measurelabel=[measurelabels{w-1} ' ' measurelabels{w} ' ' measurelabels{w+1}];
        new_wordtype='measure';
    case 'measure,measure'
        if length(results_list{w-1})~=length(results_list{w+1})
            logmsg(['results lists of ' measurelabels{w-1} ' and ' ...
                measurelabels{w+1} 'incongruent in length.'])
            return
        end
        new_results = cell(length(results_list{w-1}),1);
        new_dresults = cell(length(results_list{w-1}),1);
        for r=1:length(results_list{w-1})
            eval(['new_results{r}=results_list{w-1}{r}' operator 'results_list{w+1}{r};']);
            new_dresults{r}=nan*new_results{r};
        end
        new_measurelabel=[measurelabels{w-1} ' ' measurelabels{w} ' ' measurelabels{w+1}];
        new_wordtype='measure';
end
wordtypes={ wordtypes{1:w-2},new_wordtype,wordtypes{w+2:end}};
measurelabels={measurelabels{1:w-2},new_measurelabel,measurelabels{w+2:end}};
results_list={ results_list{1:w-2} ,new_results,results_list{w+2:end}};
dresults_list={ dresults_list{1:w-2} ,new_dresults,dresults_list{w+2:end}};

return


function [word,wordtype,rest]=get_next_word(sentence)

rest = strtrim(sentence);
word = '';
if isempty(rest)
    return
end
if is_digit(rest(1))
    wordtype='scalar';
    while is_digit(rest(1))
        word(end+1)=rest(1); %#ok<AGROW>
        rest=rest(2:end);
        if isempty(rest)
            break
        end
    end
    if strcmp(word,'-')
        wordtype='operator';
    end
elseif is_letter(rest(1))
    open_square_bracket = 0;
    while (~is_operator(rest(1)) && rest(1)~='(') || open_square_bracket
        if rest(1)=='['
            open_square_bracket = open_square_bracket+1;
        elseif rest(1)==']'
            open_square_bracket = open_square_bracket-1;
            if open_square_bracket<0
                errormsg('Too many closing brackets',true);
            end
        end
        word(end+1)=rest(1); %#ok<AGROW>
        rest=rest(2:end);
        if isempty(rest)
            break
        end
    end
    word = strtrim(word);
    switch exist(word) %#ok<EXIST>
        case {2,5}
            wordtype='function';
        otherwise
            wordtype='measure';
    end
elseif is_operator(rest(1))
    wordtype='operator';
    word=rest(1);
    rest=rest(2:end);
elseif rest(1)=='('
    wordtype='compound';
    depth=1;
    word='(';
    rest=rest(2:end);
    while ~isempty(rest) && depth>0
        word(end+1)=rest(1); %#ok<AGROW>
        rest=rest(2:end);
        switch word(end)
            case '('
                depth=depth+1;
            case  ')'
                depth=depth-1;
        end
    end
    if depth>0 % unclosed bracket
        wordtype='unknown';
        errormsg(['Unclosed bracket in ' sentence ],true);
        word=rest;
        rest='';
    end
else
    wordtype='unknown';
    errormsg(['Cannot parse measures ' sentence ],true);
    word=rest;
    rest='';
end
return

function r=is_digit( ch )
digits='-.0123456789';
r= ~isempty(strfind(digits,ch));

function r=is_letter(ch)
letters='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
r= ~isempty(strfind(letters,ch));

function r=is_operator(ch)
operators='^*/+-<>=!|&';
r= ~isempty(strfind(operators,ch));

