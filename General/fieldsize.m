function sizes = fieldsize( db )
%FIELDSIZE returns memory occupied by each field of a array of structures
%
% 2013, Alexander Heimel

st = whos('db');
disp(['Total: ' num2str(st.bytes)]);
flds = fieldnames(db);
for i=1:length(flds)
    dbn = rmfield(db,flds{i});
    s = whos('dbn');
    sizes(i) = st.bytes-s.bytes;
    try
        x = [db.(flds{i})];
    catch
        x = [];
    end
    sx = whos('x');
    disp([flds{i} ': Assigned ' num2str(sizes(i)) ', needed ' num2str(sx.bytes)]);
end
for j=1:length(db)
    for i=1:length(flds)
        ndb.(flds{i})(j,:) =db(j).(flds{i});
    end
end
whos('ndb')

%sum(sizes)
