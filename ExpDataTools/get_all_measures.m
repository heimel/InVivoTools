function measures_db = get_all_measures

h = waitbar(0,'Loading all measures');
measures_db = [];

datatypes = {'tp','ec','oi'};
for i=1:length(datatypes)
    measures_db = extract_db( measures_db, datatypes{i});
end
close(h);    
if ~nargout
    show_table(measures_db);
end


function measures_db = extract_db( measures_db, datatype)

% get which database
testdb = expdatabases( datatype );

[db,filename]=load_expdatabase( testdb,'',false,false,true );
if isempty(db)
    return
end

logmsg(['Extracting ' datatype]);
measures = {};
measures = extract_measures(db,measures);

for i=1:length(measures)
    measures_db(end+1).name = [datatype ':' measures{i}];
    measures_db(end).label = measures{i};
    measures_db(end).datatype = datatype;
    measures_db(end).stim_type = '';
    measures_db(end).point = '';
    measures_db(end).measures = [datatype ':' measures{i}];
end
    




function measures = extract_measures(db,measures)
if nargin<1
    measures = {};
end

for i=1:length(db)
    if isfield(db(i),'measures') && isstruct(db(i).measures)
        measures = uniq(sort(cat(1,measures,fieldnames(db(i).measures))))';
    end
end