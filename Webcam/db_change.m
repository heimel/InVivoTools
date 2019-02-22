db = load_testdb('wc');

for i=1:length(db)    
    if ~isempty(db(i).measures) && isfield(db(i).measures,'frame1')
        if  ~isempty(db(i).measures.frame1)
            firstframe = db(i).measures.frame1;
            filename = fullfile(experimentpath(db(i)),'firstframe.mat');
            save(filename, 'firstframe');
            db(i).measures = rmfield(db(i).measures,'frame1');
        end
    end
end

save_db(db, 'wctestdb_tinyhat')
