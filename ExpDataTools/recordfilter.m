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
    if isfield(record,'epoch'); % i.e. tp
        s = ['mouse=' record.mouse ',date=' record.date ',epoch=' record.epoch ',stack=' record.stack];
    else
        s = ['mouse=' record.mouse ',date=' record.date ',test=' record.test ',datatype=' record.datatype];
    end
    return
end
flds = fields(record);
s = [flds{1} '=' record.(flds{1})];

ind = find_record(db,s);
unique_record = (length(ind)==1);
f = 2;
while ~unique_record && f<=length(flds)
    if isstruct(record.(flds{f}))
        f = f + 1;
        continue
    end
    s = [s ',' flds{f} '=' record.(flds{f})];
    ind = find_record(db,s);
    unique_record = (length(ind)==1);
    f = f + 1;
end

