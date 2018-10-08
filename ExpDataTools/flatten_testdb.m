function flatdb = flatten_testdb(db)
%FLATTEN_TESTDB flatten measures struct array into main database structarray
%
% FLATDB = FLATTEN_TESTDB( DB )
%
% 2017, Alexander Heimel

flatdb = db;

if ~isfield(db,'measures')
    return
end

flatdb = db(1);
flatdb = rmfield(flatdb,'measures');
flatdb = flatdb([]);
for i=1:length(db)
    record = db(i);
    record = rmfield(record,'measures');
    if isempty(db(i).measures)
        newrec = structconvert(record,flatdb,false);
        flatdb(end+1) = newrec;
        continue
    end
    for j=1:length(db(i).measures)
        newrec = catstruct(record,db(i).measures(j));
        newrec = structconvert(newrec,flatdb,false);
        flatdb = structconvert(flatdb,newrec,false);
        flatdb(end+1) = newrec;
    end
end

% remove all nan and all zero, and series fields
table_measures = flatdb;
flds = fieldnames( table_measures );
for field = flds'
    if iscell(table_measures(1).(field{1}))
        table_measures = rmfield(table_measures,field{1});
    elseif isstruct(table_measures(1).(field{1}))
        table_measures = rmfield(table_measures,field{1});
    elseif ischar(table_measures(1).(field{1}))
        % do nothing
    elseif any(cellfun(@numel,{table_measures.(field{1})})>1)
        % throw out arrays
        table_measures = rmfield(table_measures,field{1});
    elseif all(isnan( cat(1,table_measures.(field{1})) ))
        table_measures = rmfield(table_measures,field{1});
    elseif ~(any( [table_measures.(field{1})] ))
        table_measures = rmfield(table_measures,field{1});
    elseif ~isempty(strfind(field{1},'series'))
        table_measures = rmfield(table_measures,field{1});
    end
end
flatdb = table_measures;