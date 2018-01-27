function s = recordfilter( record,db)
%RECORDFILTER returns a filter to uniquely identify a given record
%
%  S = RECORDFILTER( RECORD, DB )
%
% 2013, Alexander Heimel
%

if nargin<2
    db=[];
end

if isempty(db) % very leveltlab specific
    s = '';
    s = addfield( s, record, 'mouse');
    s = addfield( s, record, 'date');
    [s,tp] = addfield( s, record, 'epoch');
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
unique_record = (length(ind)==1);
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
    unique_record = (length(ind)==1);
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
if ~isempty(str)
    str(end+1)=',';
end

str = [str field '=' record.(field)];

