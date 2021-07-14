function ind=test2ind(tests,record,db)
%TEST2IND finds records in database corresponding tot testnames
%
%  IND=TEST2IND(TESTNAMES,RECORD,DB)
%       TESTNAMES is comma-separated string of testnames,
%          e.g. 'mouse_ks_E16, 2005-01-26/mouse_ks_E17'
%          or a cell-list of names
%
% 2005, Alexander Heimel
%

ind=[];
if isempty(tests)
    return
end
if ~iscell(tests)
    tests = ivt_split(tests,',');
end
for i=1:length(tests)
    indslash=find(tests{i}=='/');
    switch length(indslash)
        case 0,
            day=record.date;
            test=strtrim(tests{i});
        case 1,
            day=strtrim( tests{i}(1:indslash-1) );
            test=strtrim( tests{i}(indslash+1:end));
        otherwise
            errormsg('More than one slash in test-specification');
            return
    end
    crit = { ['date=' day ], ['test=' test ]};
    ind = [ind find_record(db,crit)];
end
