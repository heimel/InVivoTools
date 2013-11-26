function recalculate_all_intensities(dbfilename, filter)
%RECALCULATE_ALL_INTENSITIES is temporary tool to recalculate all 2p puncta
%
% 2011, Alexander Heimel
%


if nargin<1
    filter = [];
end

[db,dbfilename] = load_testdb(dbfilename);
ind = find_record(db,filter);

for i = ind
    if isempty(db(i).ROIs)
        continue
    end
    if isempty( db(i).ROIs.celllist )
        continue
    end
    if toc(uint64(str2double(db(i).analysed)))<15*60 % done less than 15 minutes ago
        continue
    end
   db(i).ROIs.celllist = tp_get_intensities(db(i));
   db(i).analysed = num2str(tic);
end

% save database
[filename,lockfile] = save_db(db, dbfilename );
if ~isempty(lockfile)
    rmlock(filename);
end
   
 

    
