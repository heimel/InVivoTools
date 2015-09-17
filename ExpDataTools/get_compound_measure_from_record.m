function [val,val_sem]=get_compound_measure_from_record(record,measure,criteria,extra_options)
%GET_COMPOUND_MEASURE_FROM_RECORD gets formulaic measures from record
%
%  [val,val_sem]=get_compound_measure_from_record(record,measure,criteria,extra_options)
%
% 2014, Alexander Heimel
%

measure = strtrim(measure);

%logmsg(measure)

if measure(1)=='['
    if ~measure(end)==']'         
        errormsg('Missing end ]-bracket',true);
    end
    measure = measure(2:end-1); % strip [-]
end

if isnumber(measure)
    val = str2double(measure);
    val_sem = 0;
    return
end

ops = find(is_operator(measure),1);
ob = find(measure=='(',1);

if isempty(ops) ||  length(find(measure(1:ops-1)=='('))~= length(find(measure(1:ops-1)==')'))
    % i.e. no compound
    %(~isempty(ob) && ob<ops && measure(end)==')')
    if isempty(ob) % no '(' 
        [val,val_sem] = get_measure_from_record(record,measure,criteria,extra_options);
        return
    end       
    % '(' present
    if measure(end)~=')'
        errormsg('Missing end (-bracket',true);
    end
    if ob==1
        [val,val_sem] = get_measure_from_record(record,measure(2:end-1),criteria,extra_options);
        return
    end
    % must be a function call
    head = measure(1:ob-1);
    tail = measure(ob+1:end-1);
    val = get_compound_measure_from_record(record,tail,criteria,extra_options);
    if exist(head,'builtin') || exist(head,'file')
        val = feval(head,val);
        val_sem = NaN(size(val));
        return
    else
        errormsg(['Don''t know how to handle ' head],true);
    end
end

% i.e. compound
op = measure(ops);
head = measure(1:ops-1);
tail = measure(ops+1:end);
    valh = get_compound_measure_from_record(record,head,criteria,extra_options);
    valt = get_compound_measure_from_record(record,tail,criteria,extra_options);
switch op
    case '+'
        val = valh+valt;
    case '-'
        val = valh-valt;
    case '*'
        val = valh.*valt;
    case '/'
        val = valh./valt;
    case '^'
        val = valh.^valt;
end
val_sem = NaN(size(val));


function res = isnumber(str)
res = all(ismember(str,'-+0123456789.'));
    
function res = is_operator(str)
res = ismember(str,'+-/^*');