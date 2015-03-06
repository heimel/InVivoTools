%make_unused_stacks_unreliable
%
%  makes stacks that Laura has not analyzed (e.g. if they were outside the LPZ)
% unreliable
%
% 2015, Alexander Heimel



%exp = experiment('11.12_alexander');
exp = experiment('11.12');

logmsg(['Setting unanalyzed stack of ' exp ' to unreliable']);

% get which database
[testdb, experimental_pc] = expdatabases( 'tp','olympus');
[db,filename]=load_testdb(testdb);

for i=1:length(db)
    if ischar(db(i).reliable)
        if isempty(db(i).reliable)
            db(i).reliable = [];
        else
            try
                db(i).reliable  = eval(db(i).reliable);
            catch me
                db(i).reliable
                db(i).comment = [db(i).comment ' ' db(i).reliable];
                db(i).reliable = [];
            end
        end
    end
end

% see email Laura to Alexander on 2015-01-15
crit = ['(mouse=11.12.32,stack=xyz4)|' ... % out off lesion projection zone 
    '(mouse=11.12.32,stack=xyz2)|' ...  % % out off lesion projection zone
    '(mouse=11.12.32,stack=xyz5)|' ...% out off lesion projection zone
    '(mouse=11.12.33,stack=xyz1)|' ...% out off lesion projection zone
    '(mouse=11.12.33,stack=xyz2)|' ...% out off lesion projection zone
    '(mouse=11.12.33,stack=xyz3)|' ...% out off lesion projection zone
    '(mouse=11.12.33,stack=xyz4)|' ...% out off lesion projection zone
    '(mouse=11.12.47,stack=xyz1)|' ...% out off lesion projection zone
    '(mouse=11.12.49,stack=xyz2)|' ...% out off lesion projection zone
    '(mouse=11.12.59,stack=xyz1)|' ...% out off lesion projection zone
    '(mouse=11.12.61,stack=xyz1)|' ...% out off lesion projection zone
    '(mouse=11.12.65,stack=xyz1)|' ...% done by Philippe
    '(mouse=11.12.65,stack=xyz4)|' ...% done by Philippe
    '(mouse=11.12.28,stack=xyz1)|' ...% done by Philippe
    '(mouse=11.12.31,stack=xyz4)|' ...% done by Philippe
    '(mouse=11.12.72,stack=xyz3)' ...% done by Philippe
    '(mouse=11.12.72,stack=xyz4)' ...% done by Philippe?
    ];
%[db,filename,perm,lockfile]=open_db( filename, loadpath, filter)

ind = find_record(db,crit);
for i = ind
    db(i).reliable = 0;
end


if ~checklock(filename)
    logmsg(['Saving database ' filename]);
    filename = save_db(db,filename,'');
    rmlock(filename);
else
    logmsg(['Database ' filename ' is locked. Cannot save']);
end
