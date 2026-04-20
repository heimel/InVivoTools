%% Read YAML examples, compare with expected, check self-consistency
ex={%input YAML string              expected data (join=0)
    '1 #comment'                    1                                       %double (comments are ignored)
    '1.23'                          1.23                                    %double
    '"1.23"'                        '1.23'                                  %number as text
    'text'                          'text'                                  %text (yaml and MatLab quote type does not matter)
    'True'                          true                                    %boolean (yaml capitalisation does not matter)

    '[1, 2]'                        {1 2}                                   %cell
    '[[1, 2], 3]'                   {{1 2} 3}                               %nested cell
    '[1, abc, true]'                {1 'abc' true}                          %cell with mixed types
    
    'Parameter: 1'                  struct('Parameter',1)                   %struct
    sprintf('A:\n  B: 1\n  C: 2')   struct('A',struct('B',1,'C',2))         %nested struct
    sprintf('A: 1\nB: b\nC: true')  struct('A',1,'B','b','C',true)          %struct with mixed types

    ['a: 1' 10 'b: [2, c]']         struct('a',1,'b',{{2 'c'}})             %struct containing cells
    sprintf('- A: 1\n- A: 2')       {struct('A',1) struct('A',2)}           %cell containing structs

    '2000-01-02'                    datetime(2000,1,2,'TimeZone','UTC')     %datetime (implicit)
    '!!timestamp "2000-01-02"'      datetime(2000,1,2,'TimeZone','UTC')     %datetime (explicit)
    '2000-01-02T03:04:05.1239Z'     datetime(2000,1,2,3,4,5.124,'TimeZone','UTC') %time with millisec (microseconds are rounded)
    '2000-01-02T05:04:05+02:00'     datetime(2000,1,2,3,4,5,'TimeZone','UTC') %time with millisec

    'null'                          []                                      %empty double
    '~'                             []                                      %empty double
    ''                              []                                      %empty double
    '""'                            ''                                      %empty string
    '[]'                            {}                                      %empty cell
    '{}'                            struct()                                %struct with no fields
    'a: '                           struct('a',[])                          %struct with empty field
    '.nan'                          NaN                                     %not a number
    '.inf'                          Inf                                     %positive infinity
    '-.inf'                         -Inf                                    %negative infinity

    '1a: 1'                         struct('x1a',1)                         %field that start with numbers
    sprintf('A-B: 1/nA+B: 2')       struct('A_B',1,'A_B_1',2)               %fields with invalid characters, or non unique fields
    };

for k = 1:size(ex,1)-2
    fprintf('\nTest #%g\n',k)
    yaml_example = ex{k,1}
    data_read = yamlread(yaml_example,0)
    yaml_written = yamlwrite(data_read)
    data_reread = yamlread(yaml_written,0)
    t1 = isequaln(data_read,ex{k,2}); fprintf(2-t1,'Varified: %g\n',t1);   %was expected result obtained
    t2 = isequaln(data_read,data_reread);   fprintf(2-t2,'Consistent: %g\n',t2); %is read > write > read is self-consistent
    assert(t1&t2) %stop if test fails
end

%% Write data to YAML and then read it, check self-consistency
ex={%input data                       join=
    [1 2]                               1       %row vector
    {1 2}                               0       %row vector (as cells)
    [1;2]                               1       %col vector
    {{1} {2}}                           0       %col vector (as cells)
    [1 2;3 4]                           1       %2d array
    {{1 2} {3 4}}                       0       %2d array  (as cells)
    cat(3,[1 2;3 4],[5 6;7 8])          1       %3d array
    {{{1 2} {3 4}},{{5 6} {7 8}}}       0       %3d array  (as cells)
    [true false]                        1       %row logical
    {true false}                        0       %row logical (as cells)
    [true false;false true]             1       %2d logical
    {{true false} {false true}}         0       %2d logical  (as cells)
    struct('A',{1 2})                   1       %row of structs
    {struct('A',1) struct('A',2)}       0       %row of structs (as cells)
    struct('A',{1;2})                   1       %col of structs
    {{struct('A',1)} {struct('A',2)}}   0       %col of structs (as cells)
    }; 

for k = 1:size(ex,1)
    fprintf('\nTest #%g\n',k)
    [data_to_write,join] = ex{k,:};
    yaml_written = yamlwrite(data_to_write)
    data_read = yamlread(yaml_written,join)
    t1 = isequaln(data_read,data_to_write);
    fprintf(2-t1,'Varified: %g\n',t1);           %was expected result obtained
    assert(t1) %stop on error
end

%% fails
ex={%input data          %join=
    {[1 2] [1 2;3 4]}      1
    };
for k = 1 %1 %:size(examples,1)
    fprintf('\nTest #%g\n',k)
    [data,join] = ex{k,:}
    yaml = yamlwrite(data);
    out = yamlread(yaml,join)
    t1 = isequaln(out,ex{k,1});
    fprintf(2-t1,'Varified: %g\n',t1)
end

%% Read YAML files in a folder, check self-consistency (join=0)
files = dir('**\*.yaml');
files = fullfile({files.folder},{files.name});
for k = 5:numel(files)
    fprintf('%s',files{k})
    data_read = yamlread(files{k},0);     fprintf(', read: ok')             %read
    yamlwrite(data_read,'out.yaml');    fprintf(', write: ok')              %write
    data_reread = yamlread('out.yaml',0); fprintf(', consistent: %d\n',isequal(data_read,data_reread)) %consistent
end