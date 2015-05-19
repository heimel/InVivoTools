function test_invivotools( datatypes, breakonerror)
%TEST_INVIVOTOOLS analyses example databases and checks results
%
%  TEST_INVIVOTOOLS( DATATYPES, BREAKONERROR)
%      DATATYPES is a cell list with datatype strings. Use empty to
%      test only graph_db
%
%  useful for checking software after making changes
%
% 2015, Alexander Heimel

if nargin<1 || isempty(datatypes)
    datatypes = {};
end
if nargin<2 || isempty(breakonerror)
    breakonerror = true;
end

prev_exp = experiment;
experiment('examples')

% experiment databases
for d = 1:length(datatypes)
    logmsg(['Testing examples for datatype ' datatypes{d}]);
    db = load_testdb( datatypes{d} );
    for i=1:length(db)
        record = db(i);
        prev_values = record.measures;
        record = analyse_testrecord(record,false);
        if ~isempty(prev_values)
            if ~isequaln(record.measures,prev_values)
                errormsg([recordfilter(record,db) ' does not give the same values as previously ']);
                if length(record.measures)~=length(prev_values)
                    logmsg(['Difference in the number of cells or ROIs. ' ...
                        'Previously ' num2str(length(prev_values)) ...
                        ', now ' num2str(length(record.measures))]);
                else
                    
                end
                
                if breakonerror
                    keyboard
                end
            end
        end
    end
end

% graph database
db = load_graphdb;
for i=1:length(db)
    record = db(i);
    prev_values = record.values;
    record = compute_graphrecord(record,db);
    if ~isempty(prev_values)
        if ~isequaln(record.values.gx,prev_values.gx) || ...
                ~isequaln(record.values.gy,prev_values.gy) || ...
                ~isequaln(record.values.p,prev_values.p)
            errormsg([recordfilter(record,db) ' does not give the same values as previously ']);
            if breakonerror
                keyboard
            end
        end
    end
end

experiment(prev_exp);