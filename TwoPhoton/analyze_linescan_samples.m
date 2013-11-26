function analyze_linescan_samples
%ANALYZE_LINESCAN_SAMPLES figures out which parameters are optimal
%
% Related function ANALYZE_TPLINESCANS, TPLINESCANDB
%
% 2010, Alexander Heimel
%
db = [];
filename = 'tplinescan_sample_db.mat';
datapath = fileparts(which('tplinescandb'));
filename = fullfile( datapath, filename );
load(filename,'-mat');

compare_process_params = db(1).process_params;
compare_process_params.filter.parameters = nan;
compare_process_params.detect_events_threshold = nan;
compare_process_params.detect_events_group_width = nan;

comments = {};

for i=1:length(db)
%    if isempty(db(i).comment)

        [temp,fname]=fileparts(tpfilename(db(i)));
        
        n_waves = sum( db(i).result.waves );
        comment = [fname ', #waves = ' num2str(n_waves,'%03.f') ', '];
        comment = [comment showstructdiffs(db(i).process_params, compare_process_params)];
        db(i).comment = comment;
        %fprintf(comment)
       %fprintf('\n');
        %    end
        comments{end+1} = comment;
end
save(filename,'-mat');

fid = fopen( fullfile(datapath,'waves_log.csv'),'w');
comments = sort(comments);
for i = 1:length(comments)
    fprintf(fid,[comments{i} '\n']);
    disp(comments{i});
end
fclose(fid);



function res = showstructdiffs( a, b)
res = '';
[c,dfields] = structdiff(a,b);
%dfields
for field = dfields
    content = a.(field{1});
    if islogical(content)
        content = double(content);
    end
    if isnumeric(content)
        content = num2str(content);
    end
    if isstruct(content)
        res = [res sprintf([field{1} ':']) ];
        res = [res showstructdiffs(a.(field{1}),b.(field{1}))];
    else
        res = [res sprintf([field{1} ' = ' content ', ' ]) ];
    end
end
