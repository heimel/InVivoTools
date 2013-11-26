function save_measures( testrecord, measures )
%SAVE_MEASURES saves measures for cells or ROIs for specific test into databases
%
% 2012, Alexander Heimel
%


% try to add measures to specific stimscript database
dbfilename = [record.datatype '_' record.stimscript '_db.mat'];
dbfilename = fullfile(expdatabasepath,dbfilename);
[db,dbfilename,perm,lockfile] = open_db(dbfilename);
if isempty(db)
	disp(['ANALYSE_ECTESTRECORD: No measure database for script ' record.stimscript ]);
end

if isempty(find(perm,'w')) % i.e. not managed to get a lock
    disp(['ANALYSE_ECTESTRECORD: Cannot save data in ' filename ])
    return;
end

%return

% remove existing measurements
ind = find_record(db,['mouse=' record.mouse ',date=' record.date ',test=' record.test ]);
db = del_record(db,ind);

% add new measurements
for i=1:length(measures)
	if ~isempty(db)
		measure_record = empty_record(db);
	end
	measure_record.mouse = record.mouse;
    measure_record.date = record.date;
    measure_record.test = record.test;
    
    measure_record.cell_nr = get_cellnumber( record, i);
    measure_record.template_nr = i;
    
    flds = fields(measures);
    for f = 1:length(flds)
        measure_record.(flds{f}) = measures(i).(flds{f});
	end
	if ~isempty(db)
        try
            db(end+1) = measure_record;
        catch
            db = measure_record;
        end
	else
		db = measure_record;
	end
end

% save and remove lock
save_db(db,dbfilename,'',lockfile);
rmlock(dbfilename);

