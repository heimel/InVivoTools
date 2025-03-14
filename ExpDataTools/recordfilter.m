function s = recordfilter( record,db)
%RECORDFILTER returns a filter to uniquely identify a given record
%
%  S = RECORDFILTER( RECORD, DB )
%
% 2013-2023, Alexander Heimel
%

if nargin<2
    db=[];
end

if isempty(db) % lab specific
    s = '';
    s = addfield( s, record, 'mouse');
    s = addfield( s, record, 'subject');
    s = addfield( s, record, 'date');
    [s,tp] = addfield( s, record, 'epoch');
    s = addfield( s, record, 'sessionid');
    s = addfield( s, record, 'sessnr');
    s = addfield( s, record, 'condition');
    s = addfield( s, record, 'stimulus');
    if tp
        s = addfield( s, record, 'stack');
    else
        s = addfield( s, record, 'test');
        s = addfield( s, record, 'datatype');
    end
    return
end
flds = fieldnames(record);
s = [flds{1} '=' record.(flds{1})];

ind = find_record(db,s);
unique_record = (isscalar(ind));
f = 2;
while ~unique_record && f<=length(flds)
    if isstruct(record.(flds{f}))
        f = f + 1;
        continue
    end
    if isnumeric(record.(flds{f}))
        val = mat2str(record.(flds{f}));
    else
        val = record.(flds{f});
    end
    s = [s ',' flds{f} '="' val '"' ];
    ind = find_record(db,s);
    unique_record = (isscalar(ind));
    f = f + 1;
end

function [str,pres]=addfield( str, record, field)
pres = false;
if ~isfield(record,field)
    return
end
pres = true;
if isempty( record.(field)) 
    return
end
if isnumeric(record.(field))
    val = num2str(record.(field));
else
    val = record.(field);
end
if ~isempty(str)
    str(end+1)=',';
end
str = [str field '=' val];

