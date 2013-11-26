%  script (not function) to analyze ctx data

global ctx_databaseNLT

cells = load(ctx_databaseNLT,'-mat');
cellnames = fieldnames(cells);
minipath = '/hog1/minis/';
newcells = cells;

for i=1:length(cells),

	% for all cells in this exper, name ends with date
	expername = cellnames{i}; expername=expername((end-9):end);
	expername(find(expername=='_'))='-';
	cksds = cksdirstruct([minipath expername]);

	newcell{i} = cells{i};
    %newcell{i} = ctxrevcorranalysis(cksds,newcell{i});
    newcell{i} = ctxcentsizeanalysis(cksds,newcell{i});
end;

% 
